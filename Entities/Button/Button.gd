extends Node3D

class_name CollisionButton

@export var untriggerable: bool = false

@onready var gem: MeshInstance3D = $Gem
@onready var swirl: MeshInstance3D = $Swirl
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer

@onready var gemStartPos = gem.position

var isTriggered = false

signal triggered
signal untriggered

var time: float = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !isTriggered:
		time += delta
		gem.position.y = gemStartPos.y + sin(time * 2) * 0.25
		gem.rotation.y += delta
	swirl.rotation.y += -delta
	
func trigger() -> void:
	triggered.emit()
	isTriggered = true
	animationPlayer.play("Deactivate")
	
func untrigger() -> void:
	untriggered.emit()
	isTriggered = false
	animationPlayer.play("Activate")
	await animationPlayer.animation_finished
	animationPlayer.play("Default")

func _on_trigger_body_entered(body: Node3D) -> void:
	if body is Player:
		if !isTriggered:
			trigger()
		elif untriggerable:
			untrigger()
