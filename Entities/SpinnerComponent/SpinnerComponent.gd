@tool
extends Node

class_name SpinnerComponent

@export var spinSpeed: float
@export var axis: Vector3 = Vector3.UP
@onready var parent: Node3D = $".."

func _process(delta: float) -> void:
	parent.rotate_object_local(axis, spinSpeed * delta)
