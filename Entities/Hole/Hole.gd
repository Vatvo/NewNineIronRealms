extends Area3D


@export var winUI: PackedScene
@export var level: Node

func _ready() -> void:
	body_entered.connect(win)

func win(body: Node3D) -> void:
	if body is Player:
		print("win")
		get_tree().paused = true
		var winScreen = winUI.instantiate()
		get_tree().root.add_child(winScreen)
