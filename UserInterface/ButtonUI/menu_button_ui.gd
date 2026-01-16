extends HBoxContainer

@onready var MenuBtn: Button = $Button
@onready var Animator: AnimationPlayer = $"../AnimationPlayer"

func _ready() -> void:
	$ArrowImg.modulate = 0
	MenuBtn.pressed.connect(button_pressed)
	MenuBtn.mouse_entered.connect(hover_play)
	MenuBtn.mouse_exited.connect(hover_stop)

func button_pressed() -> void:
	pass

func hover_play() -> void:
	Animator.play("ArrowFade")

func hover_stop() -> void:
	Animator.stop()
