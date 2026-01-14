extends Node3D

class_name AimMarker

@onready var ball: RigidBody3D = $".."

func draw_aim(shotForce: Vector3, aimLength) -> void:
	for child in get_children():
		child.queue_free()
	
	var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
	var timeStep := 0.05
	
	var velocity: Vector3 = Vector3(shotForce.x, shotForce.y, shotForce.z).normalized() * 30
	
	var initPosition: Vector3 = ball.global_position
	
	var linearDamp: float = ball.linear_damp + ProjectSettings.get_setting("physics/3d/default_linear_damp", 0)
	
	var markerStart: Vector3 = initPosition
	var markerEnd: Vector3 = initPosition
	
	for i in range(1, aimLength + 1):
		markerEnd = markerStart
		markerEnd += velocity * timeStep
		
		velocity *= clampf(1.0 - linearDamp * timeStep, 0, 1)
		
		var point = MeshInstance3D.new()
		var size = lerp(0.25, 0.8, 1 - i / aimLength)
		point.scale = Vector3(size, size, size)
		point.mesh = SphereMesh.new()
		point.position = markerEnd
		#point.material_override = load("res://Materials/ShotAimMarker.tres")
		add_child(point)
			
		var ray := raycast_query(markerStart, markerEnd + markerEnd.normalized())
		
		if ray.has("collider") && ray["collider"] != ball:
			velocity = velocity.bounce(ray.normal) * ball.physics_material_override.bounce
			
			var leftoverTime: float = markerStart.distance_squared_to(ray.position) / markerStart.distance_squared_to(markerEnd)
			leftoverTime *= timeStep
			
			var leftoverSpeed: Vector3 = velocity
			leftoverSpeed.y -= gravity * leftoverTime
			leftoverSpeed *= (1.0 + linearDamp * leftoverTime)
			
			markerStart = ray.position
			markerStart += leftoverSpeed * leftoverTime
			
			continue
		
		markerStart = markerEnd
		
func raycast_query(start: Vector3, end: Vector3) -> Dictionary:
	var space = get_viewport().get_world_3d().direct_space_state
	var rayQuery = PhysicsRayQueryParameters3D.new()
	rayQuery.from = start
	rayQuery.to = end
	rayQuery.set_collision_mask(1)
	return space.intersect_ray(rayQuery)
