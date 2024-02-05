@tool
class_name EuclidianGraph extends Control

const _margin :float = 20

enum Display {
	CLOUD,
	LINES,
	BOX
}

@export var _display :Display = Display.LINES:
	set(v):
		_display = v
		queue_redraw()
@export var _x_axis_name :String = "X Axis":
	set(v):
		_x_axis_name = v
		queue_redraw()
@export var _y_axis_name :String = "Y Axis":
	set(v):
		_y_axis_name = v
		queue_redraw()
@export_range(2, 20, 1) var _nb_metrics_x: int = 5:
	set(v):
		_nb_metrics_x = v
		queue_redraw()
@export_range(2, 20, 1) var _nb_metrics_y: int = 4:
	set(v):
		_nb_metrics_y = v
		queue_redraw()

var _plots :Array[PackedVector2Array] = []
var _category_names :Array[String] = []
var _colors :Array[Color] = []

var _origin_position :Vector2
var _x_axis_end_position :Vector2
var _y_axis_end_position :Vector2
var _space_to_draw :Vector2

var _min_x: float = 0
var _max_x: float = 100
var _min_y: float = 0
var _max_y: float = 100
var _x_unit: int = 5
var _y_unit: int = 5
var font := FontFile.new()
var font_size := 12

func _enter_tree() -> void:
	custom_minimum_size = (60 + _margin * 2) * Vector2.ONE

func _draw() -> void:
	_x_unit = (_max_x - _min_y) / _nb_metrics_x
	_y_unit = (_max_y - _min_y) / _nb_metrics_y
	_origin_position = Vector2(_margin, size.y - _margin)
	_x_axis_end_position = Vector2(size.x - _margin, _origin_position.y)
	_y_axis_end_position = Vector2(_origin_position.x, _margin)
	_space_to_draw = size - _margin * 2 * Vector2.ONE
	var x_axis_name_position = Vector2(size.x - _margin - len(_x_axis_name) * font_size / 2, size.y - _margin + font_size)
	var y_axis_name_position = Vector2(font_size, font_size)
	
	# draw x axis
	draw_line(_origin_position, _x_axis_end_position, Color.BLACK, 2, true)
	draw_string(font, x_axis_name_position, _x_axis_name, 0, -1, font_size)
	
	# draw y axis
	draw_line(_origin_position, _y_axis_end_position, Color.BLACK, 2, true)
	draw_string(font, y_axis_name_position, _y_axis_name, 0, -1, font_size)
	
	# draw graph
	match _display:
		Display.LINES: _draw_lines()
		Display.CLOUD: _draw_cloud()
		Display.BOX: _draw_box()

func _draw_metrics():
	# draw x axis metric
	var x_str_decal := Vector2(0, _margin/2)
	var x_metric_decal := Vector2(0, _margin/4)
	for i in range(_nb_metrics_x):
		var start := Vector2(_origin_position.x + _space_to_draw.x / (_nb_metrics_x + 1) * (i + 1), _origin_position.y)
		var end := start + x_metric_decal
		draw_line(start, end, Color.BLACK, -1, true)
		draw_string(font, end + x_str_decal, str(_min_x + _x_unit * (i+1)), 0, -1, 10)
		draw_dashed_line(start, Vector2(start.x, _margin), Color.GRAY)
	
	# draw y axis metric
	var y_str_decal := -Vector2(_margin/2, 2)
	for i in range(_nb_metrics_y):
		var start := Vector2(_origin_position.x, _origin_position.y - _space_to_draw.y / (_nb_metrics_y + 1) * (i + 1))
		var end := start - Vector2(_margin/4, 0)
		draw_line(start, end, Color.BLACK, 1, true)
		draw_string(font, end + y_str_decal, str(_min_y + _y_unit * (i+1)), 0, -1, 10)
		draw_dashed_line(start, Vector2(_x_axis_end_position.x, start.y), Color.GRAY)

func _draw_lines() -> void:
	_draw_metrics()
	var normalisation := Vector2(_max_x - _min_x, _max_y - _min_y)
	var scale := _space_to_draw * 0.9
	var repositioning := Vector2(_margin, _margin)
	for i in range(len(_plots)):
		var points = []
		for point in _plots[i]:
			# normalisation
			point = (point - Vector2(_min_x, _min_y)) / Vector2(_max_x, _max_y)
			# rescale and reposition
			point = point * scale + repositioning
			# invert y axis
			point.y = size.y - point.y
			points.append(point)
			draw_circle(point, 3, _colors[i])
		draw_polyline(points, _colors[i])

func _draw_cloud() -> void:
	_draw_metrics()
	var scale := _space_to_draw * 0.9
	var repositioning := Vector2(_margin, _margin)
	for i in range(len(_plots)): for point in _plots[i]:
		# normalisation
		point = (point - Vector2(_min_x, _min_y)) / Vector2(_max_x, _max_y)
		# rescale and reposition
		point = point * scale + repositioning
		# invert y axis
		point.y = size.y - point.y
		draw_circle(point, 3, _colors[i])

func _draw_box() -> void:
	pass


func plot(plots: Array[PackedVector2Array], colors :Array[Color] = [], category_names: Array[String] = []) -> void:	
	_plots = plots
	
	colors.resize(len(plots))
	category_names.resize(len(plots))
	
	_colors = colors
	_category_names = category_names
	
	var min_max := Vector4(INF, -INF, INF, -INF)
	for points in _plots:
		min_max = (points as Array[Vector2]).reduce(func(a,b): return Vector4(min(a.x, b.x), max(a.y, b.x), min(a.z, b.y), max(a.w, b.y)), min_max)
	
	var snap_value := 5
	min_max.x -= snap_value
	min_max.y += snap_value
	min_max.z -= snap_value
	min_max.w += snap_value
	
	_min_x = snappedi(min_max.x, snap_value)
	_max_x = snappedi(min_max.y, snap_value)
	_min_y = snappedi(min_max.z, snap_value)
	_max_y = snappedi(min_max.w, snap_value)
	
	queue_redraw()
