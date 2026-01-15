extends RigidBody3D

class_name Player

static var canMoveCamera: bool = true
static var canShoot: bool = true

@onready var cameraHost: PhantomCamera3D = $CameraHost
@onready var shotPullLine: Line2D = $ShotUI/ShotPullLine
@onready var shotUI: CanvasLayer = $ShotUI
@onready var aimMarker: AimMarker = $AimMarker
@onready var mainCamera: Camera3D = get_tree().get_nodes_in_group("MainCamera")[0]
@onready var cameraFollowPoint: Node3D = $CameraFollowPoint
@onready var groundRayCast: RayCast3D = $GroundRayCast


@export_category("Control Parameters")
@export var cameraSensitivity: Vector2 = Vector2(1,1)
@export var cameraDistanceCurve: Curve
@export var shotPower: float
@export var spinPower: float

var isShooting: bool = false
var currentShotPower: float = 0.0

var maxPullLength: float
var pullLength: float
var aimDirection: Vector3

var grounded: float

var unmoddedDamp: float

func _ready() -> void:
	var newCameraRotation: Vector3 = cameraHost.get_third_person_rotation()
	newCameraRotation.x = clamp(newCameraRotation.x, -PI/2 + 0.1, -0.5)
	cameraHost.set_third_person_rotation(newCameraRotation)
	cameraHost.spring_length = cameraDistanceCurve.sample(cameraHost.get_third_person_rotation().x)

func _physics_process(delta: float) -> void:
	cameraFollowPoint.global_position = global_position + (linear_velocity * delta)
	groundRayCast.position = global_position
	
	if groundRayCast.collide_with_bodies:
		grounded = true
		
	if linear_velocity.length() < 0.75:
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		canShoot = true
	else:
		canShoot = false
		
	if grounded && linear_velocity.length() > 0.1:
		unmoddedDamp = clamp(0.1 / linear_velocity.length(), 0.5, 100)
	else:
		unmoddedDamp = 0
		
	if Input.is_action_pressed("Brake"):
		angular_damp = unmoddedDamp * 2
		linear_damp = unmoddedDamp * 2
	else:
		angular_damp = unmoddedDamp
		linear_damp = unmoddedDamp
	
	
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
	if floor(lerp(0, 5, pullLength / maxPullLength)) > 0:
		var impulse: Vector3 = aimDirection * shotPower * pullLength / maxPullLength
		apply_central_impulse(impulse)
		
		var spin: Vector3 = impulse * spinPower
		apply_torque_impulse(spin.rotated(Vector3.UP, PI/2))
	else:
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
	#var oppositePlaneIntersect = raycast_mouse_to_xz_plane(screenSize - pullLineEnd)

	if planeIntersect["success"]: #&& oppositePlaneIntersect["success"]:
		var intersectPoint: Vector3 = planeIntersect["value"]
		#var oppositePoint: Vector3 = oppositePlaneIntersect["value"]
		
		return intersectPoint.direction_to(self.position)#intersectPoint.direction_to(oppositePoint)
	else:
		var screenDirection: Vector2 = (screenSize/2).direction_to(pullLineEnd)
		screenDirection.x *= -1
		screenDirection = screenDirection.rotated(mainCamera.rotation.y)
		
		return Vector3(screenDirection.x, 0, -screenDirection.y)
