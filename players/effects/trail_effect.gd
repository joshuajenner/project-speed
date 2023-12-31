class_name Trail3D
extends MeshInstance3D

var points: Array = []
var widths: Array = []
var life_points: Array = []

@export var trail_enabled: bool = true
@export var from_width: float = 0.5
@export var to_width: float = 0.0
@export_range(0.5, 1.5) var scale_acceleration: float = 1.0

@export var motion_delta: float = 0.1
@export var life_span: float = 1.0

@export var start_color := Color(1.0, 1.0, 1.0, 1.0)
@export var end_color := Color(1.0, 1.0, 1.0, 1.0)

var old_pos: Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	old_pos = get_global_transform().origin
	mesh = ImmediateMesh.new()


func _process(delta):
	if (old_pos - get_global_transform().origin).length() > motion_delta and trail_enabled:
		append_point()
		old_pos = get_global_transform().origin
	
	var p = 0
	var max_points = points.size()
	while p < max_points:
		life_points[p] += delta
		if life_points[p] > life_span:
			remove_point(p)
			p -= 1
			if p < 0:
				p = 0
		max_points = points.size()
		p += 1
	
	mesh.clear_surfaces()
	
	if points.size() < 2:
		return
	
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	for i in range(points.size()):
		var t = float(i) / (points.size() - 1.0)
		var current_color = start_color.lerp(end_color, 1 - t)
		mesh.surface_set_color(current_color)
		var current_width = widths[i][0] - pow(1 - t, scale_acceleration) * widths[i][1]
		var t0 = i / points.size()
		var t1 = t
		
		mesh.surface_set_uv(Vector2(t0, 0))
		mesh.surface_add_vertex(to_local(points[i] + current_width))
		mesh.surface_set_uv(Vector2(t1, 1))
		mesh.surface_add_vertex(to_local(points[i] - current_width))
	mesh.surface_end()

func append_point():
	points.append(get_global_transform().origin)
	widths.append([
		get_global_transform().basis.x * from_width,
		get_global_transform().basis.x * from_width - get_global_transform().basis.x * to_width
	])
	life_points.push_back(0.0)

func remove_point(index):
	points.remove_at(index)
	widths.remove_at(index)
	life_points.remove_at(index)
