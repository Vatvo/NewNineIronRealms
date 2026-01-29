extends CanvasLayer

@onready var v_slider: VSlider = $VSlider
@onready var ball_type: BallType = $"../BallType"

@onready var maxValue: float = ball_type.brakeMeter
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	v_slider.value = (ball_type.brakeMeter / maxValue) * 100
