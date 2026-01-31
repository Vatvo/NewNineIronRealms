extends RigidBody3D

class_name Player

static var canMoveCamera: bool = true
static var canShoot: bool = true
static var canSteer: bool = true
static var canBrake: bool = true

@onready var cameraHost: PhantomCamera3D = $CameraHost
@onready var shotPullLine: Line2D = $ShotUI/ShotPullLine
@onready var shotUI: CanvasLayer = $ShotUI
@onready var aimMarker: AimMarker = $AimMarker
@onready var mainCamera: Camera3D = get_tree().get_nodes_in_group("MainCamera")[0]
@onready var cameraFollowPoint: Node3D = $CameraFollowPoint
@onready var groundRayCast: RayCast3D = $GroundRayCast
@onready var trail: GPUTrail3D = $Trail
@onready var circleTransition: ColorRect = $ResetFadeOut/CircleTransition
@onready var ballTypeNode: BallType = $BallType
@onready var hacksilverParticles: GPUParticles3D = $HacksilverParticles
@onready var brakeMeter: CanvasLayer = $BrakeMeter

@export_category("Ball Type")
@export var ballTypeScript: Script = preload("res://Entities/Player/BallTypes/DefaultBall.gd")

@export_category("Control Parameters")
@export var shotPower: float
@export var spinPower: float
@export var hopPower: float
@export var powerShotBound: float
@export var brakeDepeltionSpeed: float

@export_category("Camera")
@export var cameraSensitivity: Vector2 = Vector2(1,1)
@export var cameraDistanceCurve: Curve

@export_category("Audio")
@onready var HitSoundPlayer: AudioStreamPlayer3D = $HitSoundPlayer
@onready var ClubSoundPlayer: AudioStreamPlayer3D = $ClubSoundPlayer
@onready var ThunderSoundPlayer: AudioStreamPlayer3D = $ThunderSoundPlayer
@onready var ClubSoundPlayerHard: AudioStreamPlayer3D = $ClubSoundPlayerHard
@onready var JumpSoundPlayer: AudioStreamPlayer3D = $JumpSoundPlayer
@onready var BrakeSoundPlayer: AudioStreamPlayer3D = $BrakeSoundPlayer
@onready var HacksilverSoundPlayer: AudioStreamPlayer3D = $HacksilverSoundPlayer
@onready var ResetSoundPlayer: AudioStreamPlayer3D = $ResetSoundPlayer

var last_velocity: Vector3 = Vector3.ZERO

var isShooting: bool = false
var currentShotPower: float = 0.0

var maxPullLength: float
var pullLength: float
var aimDirection: Vector3

var isGrounded: float = false
var isMoving: bool = false
var isBraking: bool = false

var unmoddedDamp: float

var lastShotPosition: Vector3 = Vector3.INF

func _ready() -> void:
	circleTransition.material.set_shader_parameter("screen_width", get_viewport().size.x)
	circleTransition.material.set_shader_parameter("screen_height", get_viewport().size.y)

	ballTypeNode.set_script(ballTypeScript)
	ballTypeNode.parent = self
	
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)
	var newCameraRotation: Vector3 = cameraHost.get_third_person_rotation()
	newCameraRotation.x = clamp(newCameraRotation.x, -PI/2 + 0.1, -0.5)
	cameraHost.set_third_person_rotation(newCameraRotation)
	cameraHost.spring_length = cameraDistanceCurve.sample(cameraHost.get_third_person_rotation().x)

func _physics_process(delta: float) -> void:
	groundRayCast.position = global_position
	trail.position = global_position
	last_velocity = linear_velocity
	hacksilverParticles.global_position = position
	
	if check_is_grounded():
		isGrounded = true
	else:
		isGrounded = false
	
	if linear_velocity.length() > 0.5:
		canShoot = false
		canSteer = true
		isMoving = true
	elif isMoving:
		canShoot = true
		canSteer = false
		isMoving = false
		
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		
		if isBraking:
			deactivate_brake()
		
	if isGrounded:
		unmoddedDamp = 1 / linear_velocity.length()
	if !isGrounded || !isMoving:
		unmoddedDamp = 0
		
	if isBraking:
		if ballTypeNode.brakeMeter <= 0:
			deactivate_brake()
			
		angular_damp = unmoddedDamp * 2
		linear_damp = unmoddedDamp * 2
		ballTypeNode.brakeMeter -= brakeDepeltionSpeed * delta
		
		
	else:
		angular_damp = unmoddedDamp
		linear_damp = unmoddedDamp
	
	if Input.is_action_just_pressed("Brake") && isMoving:
		activate_brake()
	
	if Input.is_action_just_released("Brake"):
		deactivate_brake()
	
	if Input.is_action_pressed("SteerLeft") && canSteer:
		linear_velocity = linear_velocity.rotated(Vector3.UP, ballTypeNode.steerSensitivity)
		angular_velocity = angular_velocity.rotated(Vector3.UP, ballTypeNode.steerSensitivity)
		
		var currentCameraRotation := cameraHost.get_third_person_rotation()
		var newCameraRotation := currentCameraRotation
		newCameraRotation.y += ballTypeNode.steerSensitivity
		cameraHost.set_third_person_rotation(newCameraRotation)
	
	if Input.is_action_pressed("SteerRight") && canSteer:
		linear_velocity = linear_velocity.rotated(Vector3.UP, -ballTypeNode.steerSensitivity)
		angular_velocity = angular_velocity.rotated(Vector3.UP, -ballTypeNode.steerSensitivity)
		
		var currentCameraRotation := cameraHost.get_third_person_rotation()
		var newCameraRotation := currentCameraRotation
		newCameraRotation.y -= ballTypeNode.steerSensitivity
		cameraHost.set_third_person_rotation(newCameraRotation)
	
	if Input.is_action_just_pressed("Hop") && isMoving && isGrounded:
		JumpSoundPlayer.play()
		linear_velocity.y = 0
		apply_central_impulse(Vector3.UP * hopPower)
	
	if Input.is_action_just_pressed("Reset"):
		reset()
		
	cameraFollowPoint.global_rotation = Vector3.ZERO
	
		
func _process(delta: float) -> void:
	if Input.is_action_just_released("Shoot") && isShooting:
		shoot()
		
	if Input.is_action_pressed("Shoot") && canShoot:
		handle_shot()
	else:
		isShooting = false
		shotUI.visible = false
		aimMarker.visible = false
		
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_pressed("MoveCamera") && event is InputEventMouseMotion\
	&& canMoveCamera:
		var currentCameraRotation := cameraHost.get_third_person_rotation()
		var newCameraRotation := currentCameraRotation
		newCameraRotation.y -= event.relative.x * cameraSensitivity.x
		newCameraRotation.x -= event.relative.y * cameraSensitivity.y
		newCameraRotation.x = clamp(newCameraRotation.x, -PI/2 + 0.1, -0.5)
		cameraHost.set_third_person_rotation(newCameraRotation)
		
		cameraHost.spring_length = cameraDistanceCurve.sample(newCameraRotation.x)

func _on_body_entered(body: Node) -> void:
	var speed_before: float = last_velocity.length()
	var speed_after: float = linear_velocity.length()
	var impact_strength: float = max(speed_before - speed_after, 0.0)
	if impact_strength < 0.15:
		return
	if HitSoundPlayer.playing:
		HitSoundPlayer.stop()
	# Normalize
	var max_impact: float = 8.0
	var t: float = clamp(impact_strength / max_impact, 0.0, 1.0)
	# Strong curve = quiet small hits
	t = pow(t, 5.5)
	HitSoundPlayer.play()

func check_is_grounded() -> bool:
	var space := get_viewport().get_world_3d().direct_space_state
	var ray_query := PhysicsRayQueryParameters3D.new()
	ray_query.from = Vector3(position.x, position.y, position.z)
	ray_query.to = Vector3(position.x, position.y - 0.8, position.z)
	ray_query.set_collision_mask(1)
	var raycast_result := space.intersect_ray(ray_query)

	if !raycast_result.is_empty():
		return true
	else:
		return false
		
func handle_shot() -> void:
	isShooting = true
	shotUI.visible = true
	aimMarker.visible = true
		
	var screenSize: Vector2 = get_viewport().size
	maxPullLength = screenSize.y / 3
		
	var mousePos: Vector2 = get_viewport().get_mouse_position()
	var centerScreen: Vector2 = get_viewport().size / 2
		
	var centeredMousePos: Vector2 = mousePos - centerScreen
	var direction: float = atan2(centeredMousePos.y, centeredMousePos.x)
		
	pullLength = mousePos.distance_to(centerScreen)
	pullLength = clamp(pullLength, 0, maxPullLength)
		
	var pullLineEnd: Vector2 = update_pull_line(direction, pullLength)
	aimDirection = get_aim_direction(pullLineEnd, screenSize)
	aimMarker.draw_aim(aimDirection, lerp(0, 5, pullLength / maxPullLength))
		
func shoot() -> void:
	ballTypeNode.brakeMeter = ballTypeNode.maxBrake
	
	if floor(lerp(0, 5, pullLength / maxPullLength)) > 4:
		#POWER SHOT
		ClubSoundPlayerHard.play()
		lastShotPosition = position
		ballTypeNode.power_shot()
		
	elif floor(lerp(0, 5, pullLength / maxPullLength)) > 0:
		#NORMAL SHOT
		ClubSoundPlayer.play()
		
		lastShotPosition = position
		var impulse: Vector3 = aimDirection * shotPower * pullLength / maxPullLength
		apply_central_impulse(impulse)
		
		var spin: Vector3 = impulse * spinPower
		apply_torque_impulse(spin.rotated(Vector3.UP, PI/2))
	else:
		#CANCEL
		print("Cancelled")

func raycast_mouse_to_xz_plane(mousePos: Vector2) -> Dictionary:
	var plane = Plane(Vector3.UP, global_position.y)
	
	var from = mainCamera.project_ray_origin(mousePos)
	var to = mainCamera.project_ray_normal(mousePos)
	
	var intersect = plane.intersects_ray(from, to)
	if intersect:
		return {"success":true, "value":intersect}
	else:
		return {"success":false, "value":Vector3(0,0,0)}
	
func update_pull_line(direction: float, length: float) -> Vector2:
	var screenSize: Vector2 = get_viewport().size
	shotPullLine.points[0] = screenSize / 2
	var uncenteredCoords: Vector2 = Vector2(length * cos(direction), length * sin(direction))
	shotPullLine.points[1] = uncenteredCoords + (screenSize / 2)
	
	return uncenteredCoords + (screenSize/2)

func get_aim_direction(pullLineEnd: Vector2, screenSize: Vector2):
	var planeIntersect = raycast_mouse_to_xz_plane(pullLineEnd)

	if planeIntersect["success"]:
		var intersectPoint: Vector3 = planeIntersect["value"]
		
		return intersectPoint.direction_to(self.position)#intersectPoint.direction_to(oppositePoint)
	else:
		var screenDirection: Vector2 = (screenSize/2).direction_to(pullLineEnd)
		screenDirection.x *= -1
		screenDirection = screenDirection.rotated(mainCamera.rotation.y)
		
		return Vector3(screenDirection.x, 0, -screenDirection.y)
	
func activate_brake() -> void:
	if !isBraking && canBrake && ballTypeNode.brakeMeter > 0:
		brakeMeter.visible = true
		BrakeSoundPlayer.volume_db=0.5
		isBraking = true
		
		linear_velocity /= 1.75
		angular_velocity /= 1.75
		
		var cameraFOVTween: Tween = get_tree().create_tween()
		cameraFOVTween.tween_property(cameraHost, "fov", 70, 0.3)
		await cameraFOVTween.finished
		cameraFOVTween.kill()

func deactivate_brake() -> void:
	if isBraking:
		brakeMeter.visible = false
		isBraking = false
		BrakeSoundPlayer.volume_db=-50
		linear_velocity *= 1.75
		angular_velocity *= 1.75
		
		var cameraFOVTween: Tween = get_tree().create_tween()
		cameraFOVTween.tween_property(cameraHost, "fov", 75, 0.1)
		await cameraFOVTween.finished
		cameraFOVTween.kill()

func reset() -> void:
	if lastShotPosition != Vector3.INF && ballTypeNode.resetCount > 0:
		ballTypeNode.resetCount -= 1
		ResetSoundPlayer.play()
		circleTransition.material.set_shader_parameter("screen_width", get_viewport().size.x)
		circleTransition.material.set_shader_parameter("screen_height", get_viewport().size.y)
	
		var inTween: Tween = get_tree().create_tween()
		inTween.set_trans(Tween.TRANS_SINE)
		inTween.set_ease(Tween.EASE_OUT)
		inTween.tween_method(
			func(value: float): circleTransition.material.set_shader_parameter("circle_size", value),
			1.05,
			0.0,
			0.5
		)
		await inTween.finished
		inTween.kill()
		
		
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		position = lastShotPosition
		
		lastShotPosition = Vector3.INF
		
		await get_tree().create_timer(0.5).timeout
		var outTween: Tween = get_tree().create_tween()
		outTween.set_trans(Tween.TRANS_SINE)
		outTween.set_ease(Tween.EASE_IN)
		outTween.tween_method(
			func(value: float): circleTransition.material.set_shader_parameter("circle_size", value),
			0.0,
			1.05,
			0.5
		)
		await outTween.finished
		outTween.kill()
