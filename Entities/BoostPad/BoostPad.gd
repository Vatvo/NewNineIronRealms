@tool
extends Node3D

@export var width: float = 1
@export var length: float = 1
@export var force: float = 10
@export var cooldown: float = 2

@onready var mesh: MeshInstance3D = $Mesh
@onready var collision: CollisionShape3D = $Area3D/CollisionShape3D
@onready var area3d: Area3D = $Area3D
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer

var canBoost: bool = true

func _ready() -> void:
	update_scale()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		update_scale()
	
	var overlaps := area3d.get_overlapping_bodies()
	for body in overlaps:
		if body is Player:
			var zPlane: Plane = Plane(transform.basis.x, position)
			var distance: float = abs(zPlane.distance_to(body.position))
			
			if distance < 1:
				boost(body)
				
	

func boost(body: Node3D) -> void:
	if canBoost:
		animationPlayer.play("Boost")
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO
		
		var direction = -global_transform.basis.z
		body.apply_central_impulse(direction * force)
		canBoost = false
		await get_tree().create_timer(cooldown).timeout
		canBoost = true

func update_scale() -> void:
	mesh.mesh.size.x = width
	mesh.mesh.size.y = length
	collision.shape.size.x = width * 0.6
	collision.shape.size.z = length


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		Player.canBrake = false
		body.deactivate_brake()
		await get_tree().create_timer(0.5).timeout
		if body in area3d.get_overlapping_bodies():
			var direction = -global_transform.basis.z
			boost(body)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		Player.canBrake = true
