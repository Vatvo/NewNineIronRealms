extends Node

@export var button: CollisionButton
@export var door: Node3D
@export var player: Player

@export var camera: PhantomCamera3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.triggered.connect(play_cutscene)

func play_cutscene() -> void:
	print("PLAY")
	player.linear_velocity = Vector3.ZERO
	player.angular_velocity = Vector3.ZERO
	
	camera.priority = 300
	
	await get_tree().create_timer(8).timeout
	
	camera.priority = 0
