@tool
extends Path3D

class_name Bumper
@export var expansionCurve: Curve
@onready var collision_shape_3d: CollisionShape3D = $Collision/CollisionShape3D
@onready var csg_polygon_3d: CSGPolygon3D = $CSGPolygon3D

@export_tool_button("Bake Shape", "Shape3D") var bakeButton = bake_shape
@export var bounceForce: float = 40

var outTween: Tween
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bake_shape()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
			
func bake_shape() -> void:
	collision_shape_3d.shape = csg_polygon_3d.bake_collision_shape()

func bounce(body: RigidBody3D) -> void:
	
	var point: Vector3 = curve.get_closest_point(to_local(body.position))
	point.y += 0.5
	
	var direction: Vector3 = to_global(point).direction_to(body.global_position)
	body.apply_central_impulse(bounceForce * direction)
	
	csg_polygon_3d.polygon[2].x = 1
	csg_polygon_3d.polygon[3].x = 1
	
	var progress: float = 0
	
	if outTween:
		outTween.kill()
		
	outTween = get_tree().create_tween()
	outTween.tween_method(
		func(value: float): 
			progress = expansionCurve.sample((value))
			csg_polygon_3d.polygon[2].x = progress
			csg_polygon_3d.polygon[3].x = progress,
		0.0,
		1.0,
		1
	)
	
