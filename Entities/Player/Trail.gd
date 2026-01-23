extends MeshInstance3D

class_name TrailEffect


@export_category("Parameters")
@export var trailEnabled: bool = true
@export var startWidth: float = 0.5
@export var endWidth: float = 0
@export_range(0.5, 1.5) var scaleSpeed: float = 1
@export var trailSmoothness: float = 1
@export var lifeSpan: float = 1

@export_category("Colors")
@export var startColor: Color
@export var endColor: Color

var points = []
var widths = []
var lifeSpans = []

var oldPos: Vector3

func _ready() -> void:
	oldPos = get_global_transform().origin
	mesh = ImmediateMesh.new()

func _process(delta: float) -> void:
		
	position = get_parent().position
	if (oldPos - get_global_transform().origin).length() > trailSmoothness &&\
	trailEnabled:
		append_point()
		oldPos = get_global_transform().origin
		
	var idx = 0
	var maxPoints = points.size()
	while idx < maxPoints:
		lifeSpans[idx] += delta
		if lifeSpans[idx] > lifeSpan:
			remove_point(idx)
			idx -= 1
			if (idx < 0): 
				idx = 0
		
		maxPoints = points.size()
		idx += 1
	
	mesh.clear_surfaces()
	
	if points.size() < 2:
		return
		
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	for i in range(points.size()):
		var progress = float(i) / (points.size() - 1.0)
		var currentColor = startColor.lerp(endColor, 1.0 - progress)
		mesh.surface_set_color(currentColor)
		
		var currentWidth = widths[i][0] - pow(1.0 - progress, scaleSpeed) * widths[i][1]
		
		@warning_ignore("integer_division")
		var prevProgress = i / points.size()
		var nextProgress = progress
		
		mesh.surface_set_uv(Vector2(prevProgress, 0))
		mesh.surface_add_vertex(to_local(points[i] + currentWidth))
		mesh.surface_set_uv(Vector2(nextProgress, 1.0))
		mesh.surface_add_vertex(to_local(points[i] - currentWidth))
		
	mesh.surface_end()
func append_point():
	points.append(get_global_transform().origin)
	widths.append([
		get_global_transform().basis.x * startWidth,
		get_global_transform().basis.x * startWidth
		- get_global_transform().basis.x * endWidth
	])
	lifeSpans.append(0)
	
func remove_point(idx: int):
	points.remove_at(idx)
	widths.remove_at(idx)
	lifeSpans.remove_at(idx)
