extends RigidBody3D

class_name Player

static var canMoveCamera: bool = true

@onready var camera: PhantomCamera3D = $Camera

@export_category("Control Parameters")
@export var cameraSensitivity: Vector2 = Vector2(1,1)
@export var cameraDistanceCurve: Curve

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_pressed("MoveCamera") && event is InputEventMouseMotion\
	&& canMoveCamera:
		var currentCameraRotation := camera.get_third_person_rotation()
		var newCameraRotation := currentCameraRotation
		newCameraRotation.y -= event.relative.x * cameraSensitivity.x
		newCameraRotation.x -= event.relative.y * cameraSensitivity.y
		newCameraRotation.x = clamp(newCameraRotation.x, -PI/2 + 0.1, 0)
		camera.set_third_person_rotation(newCameraRotation)
		
		camera.spring_length = cameraDistanceCurve.sample(newCameraRotation.x)
		
