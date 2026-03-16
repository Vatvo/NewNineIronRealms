extends ColorRect

@onready var ffButton: Button = $FFButton

func _ready() -> void:
	ffButton.pressed.connect(speed_up)

func speed_up() -> void:
	Dialogic.Inputs.auto_skip.enabled = !Dialogic.Inputs.auto_skip.enabled
