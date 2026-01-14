extends RigidBody3D

class_name Player

static var canMoveCamera: bool = true
static var canShoot: bool = true

@onready var cameraHost: PhantomCamera3D = $CameraHost
@onready var shotPullLine: Line2D = $ShotUI/ShotPullLine
@onready var shotUI: CanvasLayer = $ShotUI
@onready var aimMarker: AimMarker = $AimMarker
@onready var mainCamera: Camera3D = get_tree().get_nodes_in_group("MainCamera")[0]
@export_category("Control Parameters")
@export var cameraSensitivity: Vector2 = Vector2(1,1)
@export var cameraDistanceCurve: Curve

var isShooting: bool = false
var currentShotPower: float = 0.0

func _ready() -> void:
	var newCameraRotation: Vector3 = cameraHost.get_third_person_rotation()
	newCameraRotation.x = clamp(newCameraRotation.x, -PI/2 + 0.1, -0.5)
	cameraHost.set_third_person_rotation(newCameraRotation)
	cameraHost.spring_length = cameraDistanceCurve.sample(cameraHost.get_third_person_rotation().x)

func _process(delta: float) -> void:
	if Input.is_action_just_released("Shoot") && isShooting:
		shoot(0, 0)
		
	if Input.is_action_pressed("Shoot") && canShoot:
		isShooting = true
		shotUI.visible = true
		aimMarker.visible = true
		
		var screenSize: Vector2 = get_viewport().size
		var maxPullLength = screenSize.y / 3
		
		var mousePos: Vector2 = get_viewport().get_mouse_position()
		var centerScreen: Vector2 = get_viewport().size / 2
		
		var centeredMousePos: Vector2 = mousePos - centerScreen
		var direction: float = atan2(centeredMousePos.y, centeredMousePos.x)
		
		var length: float = mousePos.distance_to(centerScreen)
		length = clamp(length, 0, maxPullLength)
		
		var pullLineEnd: Vector2 = update_pull_line(direction, length)
		var aimDirection = get_aim_direction(pullLineEnd, screenSize)
		aimMarker.draw_aim(aimDirection, lerp(1, 5, length / maxPullLength))
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

func shoot(direction: float, length: float) -> void:
	print("Shoot")

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
