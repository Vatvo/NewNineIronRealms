extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(kill)


func kill(body: Node3D) -> void:
	if body is Player:
		body.reset(true)
