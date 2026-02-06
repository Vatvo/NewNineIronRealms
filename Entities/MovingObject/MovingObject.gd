extends PathFollow3D

class_name MovingObject

enum Behavior {FORWARD, BACKWARD, BOUNCE}
@export var behavior: Behavior
@export var speed: float = 1
@export var startsForward: bool

var goingForward: bool = startsForward

func _physics_process(delta: float) -> void:
	match behavior:
		Behavior.FORWARD:
			forward_behavior(delta)
		Behavior.BACKWARD:
			backwards_behavior(delta)
		Behavior.BOUNCE:
			bounce_behavior(delta)

func forward_behavior(delta: float) -> void:
	progress_ratio += speed * delta
	
func backwards_behavior(delta: float) -> void:
	progress_ratio -= speed * delta
	
func bounce_behavior(delta: float) -> void:
	if progress_ratio == 0 || progress_ratio == 1:
		goingForward = !goingForward
	progress_ratio += (speed * delta) * (int(goingForward) * 2 - 1)
	progress_ratio = clamp(progress_ratio, 0, 1)
