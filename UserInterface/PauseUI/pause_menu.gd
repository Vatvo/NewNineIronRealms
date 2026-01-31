extends CanvasLayer

@onready var FadeAnimator: AnimationPlayer = $FadeAnimPlayer
@onready var SpinAnimator: AnimationPlayer = $SpinAnimPlayer
@onready var ResumeBtn: Button = $Control/MC_Buttons/VBoxContainer/ResumeBTN/HBox/Button

var canUnpause: bool = false

func _ready() -> void:
	ResumeBtn.pressed.connect(resume)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_released("Pause") && canUnpause == false:
		#
		#canUnpause = true
		pass
	
	if Input.is_action_just_released("Pause") && canUnpause:
		resume()
	
	
func pause() -> void:
	get_tree().paused = true
	FadeAnimator.play("FadeIn")
	SpinAnimator.play("RuneSpin2")
	
	
func resume() -> void:
		get_tree().paused = false
		FadeAnimator.play_backwards("FadeIn")
