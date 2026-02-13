extends Control

@onready var Animator: AnimationPlayer = $"../AnimationPlayer"

func _ready() -> void:
	Animator.play("TitleSpawn")
