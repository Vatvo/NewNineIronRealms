extends Node

@export var button: CollisionButton
@export var door: AsgardDoor
@export var player: Player

@export var camera: PhantomCamera3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.triggered.connect(play_cutscene)

func play_cutscene() -> void:
	
	player.linear_velocity = Vector3.ZERO
	player.angular_velocity = Vector3.ZERO
	
	camera.priority = 300
	
	await get_tree().create_timer(1).timeout
	door.open()
	await get_tree().create_timer(4).timeout
	
	camera.priority = 0
