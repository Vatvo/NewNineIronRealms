extends CanvasLayer

@onready var textureProgressBar: TextureProgressBar = $TextureProgressBar

@onready var ballType: BallType = $"../BallType"

@onready var maxValue: float = ballType.brakeMeter
@onready var player: Player = $".."
@onready var brake_over: GPUParticles3D = $"../BrakeOver"

@export var meterColor1: Color
@export var meterColor2: Color

@export var ballColor1: Color
@export var ballColor2: Color
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	textureProgressBar.value = 100 - (ballType.brakeMeter / maxValue) * 100
	if player.isBraking:
		ballType.material.albedo_color = lerp(ballColor2, ballColor1, ballType.brakeMeter / maxValue)
		textureProgressBar.tint_progress = lerp(meterColor1, meterColor2, pow(1 - ballType.brakeMeter / maxValue,8))
		if ballType.brakeMeter <= 0.1:
			player.BrakePoofSoundPlayer.play()
			brake_over.emitting = true
	else:
		ballType.material.albedo_color = ballColor1
