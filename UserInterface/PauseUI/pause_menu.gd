extends Control

@onready var Animator: AnimationPlayer = $"../AnimationPlayer"

var canUnpause: bool = false

func _ready() -> void:
	Animator.play("FadeIn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		#if Input.is_action_just_released("Pause") && canUnpause == false:
		await get_tree().create_timer(0.1).timeout
		canUnpause = true
