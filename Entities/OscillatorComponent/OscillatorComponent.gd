@tool
extends Node

class_name OscillatorComponent

@export var startRot: Vector3
@export var endRot: Vector3
@export var speed: float
@export var curve: Curve
@export var enabled: bool = true

@export_tool_button("Bake Start Rotation", "RotateRight") var startButton = bake_start_rot
@export_tool_button("Bake End Rotation", "RotateLeft") var endButton = bake_end_rot

var parent: Node3D 
var progress: float = 0
var positive: bool = true

func _process(delta: float) -> void:
	parent = get_parent()
	if !enabled:
		return
		
	if positive:
		if progress < 1:
			progress = clamp(progress + speed * delta, 0, 1)
		else:
			positive = false
	else:
		if progress > 0:
			progress = clamp(progress - speed * delta, 0, 1)
		else:
			positive = true
	
	parent.rotation.x = lerp_angle(startRot.x, endRot.x, curve.sample(progress))
	parent.rotation.y = lerp_angle(startRot.y, endRot.y, curve.sample(progress))
	parent.rotation.z = lerp_angle(startRot.z, endRot.z, curve.sample(progress))
			
func bake_start_rot() -> void:
	startRot = parent.rotation
	
func bake_end_rot() -> void:
	endRot = parent.rotation
