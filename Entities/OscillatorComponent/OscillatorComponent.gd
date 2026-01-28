@tool
extends Node

class_name OscillatorComponent

@export var startTransform: Transform3D
@export var endTransform: Transform3D
@export var speed: float
@export var curve: Curve
@export var enabled: bool = true

@export_tool_button("Bake Start Transform", "Transform3D") var startButton = bake_start_rot
@export_tool_button("Bake End Transform", "Transform3D") var endButton = bake_end_rot

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
	
	parent.transform = lerp(startTransform, endTransform, curve.sample(progress))
	#parent.rotation.x = lerp_angle(startTransform.x, endTransform.x, curve.sample(progress))
	#parent.rotation.y = lerp_angle(startTransform.y, endTransform.y, curve.sample(progress))
	#parent.rotation.z = lerp_angle(startTransform.z, endTransform.z, curve.sample(progress))
			
func bake_start_rot() -> void:
	startTransform = parent.transform
	
func bake_end_rot() -> void:
	endTransform = parent.transform
