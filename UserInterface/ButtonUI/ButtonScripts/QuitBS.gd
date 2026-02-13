extends HBoxContainer

@onready var MenuBtn: Button = $Button
@onready var Animator: AnimationPlayer = $"../AnimationPlayer"

@export_category("Audio")
@onready var HoverSound: AudioStreamPlayer = $HoverSound
@onready var ConfirmSound: AudioStreamPlayer = $ConfirmSound

func _ready() -> void:
	$ArrowImg.modulate = 0
	MenuBtn.pressed.connect(button_pressed)
	MenuBtn.mouse_entered.connect(hover_play)
	MenuBtn.mouse_exited.connect(hover_stop)

func button_pressed() -> void:
	ConfirmSound.play()
	print("message received")
	await get_tree().create_timer(0.39).timeout
	get_tree().quit()

func hover_play() -> void:
	HoverSound.play()
	Animator.play("ArrowFade")

func hover_stop() -> void:
	Animator.stop()
