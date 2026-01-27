extends Node3D

class_name Hacksilver

@export var meshes: Array[Mesh]
@export var spinSpeed: float
@export var oscillateSpeed: float
@export var maxOscillateHeight: float
@export var value: int = 1

@onready var mesh: MeshInstance3D = $Mesh

var time: float = 0

func _ready() -> void:
	mesh.mesh = meshes.pick_random()
	mesh.rotation.y = randf_range(-PI, PI)
	
	time = randf_range(0, 2 * PI)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	mesh.position.y = maxOscillateHeight * sin(oscillateSpeed * time) + maxOscillateHeight
	mesh.rotation.y += spinSpeed * delta


func _on_collision_body_entered(body: Node3D) -> void:
	if body is Player:
		var player = body as Player
		player.ballTypeNode.collect_money(value)
		queue_free()
