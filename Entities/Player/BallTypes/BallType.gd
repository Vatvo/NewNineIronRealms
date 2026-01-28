extends Node

class_name BallType

var parent: Player

var steerSensitivity: float = 0.003
var brakeMeter: float = 100
var jumpCount: int = 1
var resetCount: int = 1
var coyoteTime: float = 0

func begin() -> void:
	pass
	
func power_shot() -> void:
	pass
	
func ability() -> void:
	pass
	
func collect_money(value: int) -> void:
	parent.hacksilverParticles.amount = clamp(value, 0, 4)
	parent.hacksilverParticles.restart()
	
	for i in range(clamp(value, 0, 4)):
		parent.HacksilverSoundPlayer.play()
		await get_tree().create_timer(0.1).timeout
