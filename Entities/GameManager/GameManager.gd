extends Node

class_name GameManager

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		print ("yay!")
