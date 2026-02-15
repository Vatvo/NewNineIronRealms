extends Node

class_name GameManager

enum ControlMode {KEYBOARD, CONTROLLER}
static var controlMode: ControlMode = ControlMode.CONTROLLER

static var leftJoyAxis: Vector2
static var rightJoyAxis: Vector2

func _physics_process(delta: float) -> void:
	if controlMode == ControlMode.CONTROLLER:
		leftJoyAxis = Input.get_vector("LeftJoyLeft", "LeftJoyRight", "LeftJoyDown", "LeftJoyUp")
		rightJoyAxis = Input.get_vector("RightJoyLeft", "RightJoyRight", "RightJoyDown", "RightJoyUp")
