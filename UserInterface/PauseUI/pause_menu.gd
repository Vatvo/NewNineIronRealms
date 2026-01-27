extends Control

@onready var FadeAnimator: AnimationPlayer = $"../FadeAnimPlayer"
@onready var SpinAnimator: AnimationPlayer = $"../SpinAnimPlayer"

var canUnpause: bool = false

func _ready() -> void:
	FadeAnimator.play("FadeIn")
	SpinAnimator.play("RuneSpin2")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_released("Pause") && canUnpause == false:
		await get_tree().create_timer(0.1).timeout
		canUnpause = true

	if Input.is_action_just_released("Pause") && canUnpause == true:
		get_tree().paused = false
		FadeAnimator.play_backwards("FadeIn")
