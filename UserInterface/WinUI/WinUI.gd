extends Control

@onready var SpinAnimator: AnimationPlayer =  $"../RuneSpin"
@onready var FadeAnimator: AnimationPlayer =  $"../FadeAnimator"

func _ready() -> void:
	SpinAnimator.play("RunePlayIn")
	FadeAnimator.play("TextFade")
	await get_tree().create_timer(0.5).timeout
	SpinAnimator.play("RuneSpin")
