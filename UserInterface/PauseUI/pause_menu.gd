extends CanvasLayer

@onready var FadeAnimator: AnimationPlayer = $FadeAnimPlayer
@onready var VisControl: Control = $Control
@onready var SpinAnimator: AnimationPlayer = $SpinAnimPlayer
@onready var ResumeBtn: Button = $Control/MC_Buttons/VBoxContainer/ResumeBTN/HBox/Button

@export_category("Audio")
@onready var PausePlaySound: AudioStreamPlayer = $PausePlaySound

var canUnpause: bool = false

func _ready() -> void:
	hide()
	ResumeBtn.pressed.connect(resume)

func _process(delta: float) -> void:

	if Input.is_action_just_released("Pause") && canUnpause == false:
		pause()
		show()
		await get_tree().create_timer(0.1).timeout
		PausePlaySound.play()
		canUnpause = true

	if Input.is_action_just_released("Pause") && canUnpause:
		resume()
		canUnpause = false

func pause() -> void:
	get_tree().paused = true
	FadeAnimator.play("FadeIn")
	SpinAnimator.play("RuneSpin2")
	VisControl.show()
	ResumeBtn.grab_focus()

func resume() -> void:
	get_tree().paused = false
	FadeAnimator.stop()
	FadeAnimator.play_backwards("FadeIn")
	await get_tree().create_timer(0.1).timeout
	VisControl.hide()
	canUnpause = false
