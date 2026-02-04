extends CanvasLayer

@onready var FadeAnimator: AnimationPlayer = $FadeAnimPlayer
@onready var VisControl: Control = $Control
@onready var SpinAnimator: AnimationPlayer = $SpinAnimPlayer
@onready var ResumeBtn: Button = $Control/MC_Buttons/VBoxContainer/ResumeBTN/HBox/Button

var canUnpause: bool = false

func _ready() -> void:
	ResumeBtn.pressed.connect(resume)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if Input.is_action_just_released("Pause") && canUnpause == false:
		pause()
		await get_tree().create_timer(0.1).timeout
		canUnpause = true
	
	if Input.is_action_just_released("Pause") && canUnpause:
		resume()
		canUnpause = false
	
	
func pause() -> void:
	get_tree().paused = true
	FadeAnimator.play("FadeIn")
	SpinAnimator.play("RuneSpin2")
	VisControl.show()
	
func resume() -> void:
		get_tree().paused = false
		FadeAnimator.play_backwards("FadeIn")
		VisControl.hide()
		canUnpause = false
