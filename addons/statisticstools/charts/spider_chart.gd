@tool
class_name SpiderChart extends Control

@export var stat_categories: Array[QuantitativeStat]:
	set(v):
		stat_categories = v
		stat_colors.resize(len(v[0].values))
		queue_redraw()

@export_group("settings")
@export_range(1, 10, -1, "or_greater") var nb_scales :int = 3:
	set(v):
		nb_scales = v
		queue_redraw()
@export var min_values: Array[float] = []:
	set(v):
		min_values = v
		queue_redraw()
@export var max_values: Array[float] = []:
	set(v):
		max_values = v
		queue_redraw()
@export var font_size: int = 16:
	set(v):
		font_size = v
		queue_redraw()

@export_group("colors")
@export var outline_color: Color = Color.BLACK:
	set(v):
		outline_color = v
		queue_redraw()
@export var scales_color: Color = Color.WEB_GRAY:
	set(v):
		scales_color = v
		queue_redraw()
@export var stat_colors: Array[Color] = []:
	set(v):
		stat_colors = v
		queue_redraw()


func _draw() -> void:
	# rearange data
	var max_len = stat_categories.reduce(func(a, b): return max(a, len(b.values)), 0)
	for s in stat_categories: s.values.resize(max_len)
	
	# prepare drawing
	var center: Vector2 = self.size / 2
	var distance: float = min(center.x, center.y) * 0.75
	var polyline: Array[Vector2] = get_polyline(Vector2.ZERO, 1) ## normalised
	var font = FontFile.new()
	
	# draw lines from center to edge and legend
	for i in range(len(stat_categories)):
		var end_point: Vector2 = center + polyline[i] * distance
		draw_line(center, end_point, scales_color, 1, true)
		var direction: Vector2 = (end_point - center).normalized()
		var position: Vector2 = end_point + direction * 10
		draw_string(font, position, stat_categories[i].name, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	
	# draw inner lines
	for i in range(1, nb_scales):
		var innerline := polyline.map(func(a): return center + a * distance * i / nb_scales)
		draw_polyline(innerline, scales_color, 1, true)
	
	# draw outer line
	var outline := polyline.map(func(a): return distance * a + center)
	draw_polyline(outline, outline_color, 2, true)
	
	# draw stats
	var nb_stat: int = len(stat_categories[0].values)
	for i in range(nb_stat):
		var line_points :Array[Vector2] = []
		for j in range(len(stat_categories)):
			var value: float = (stat_categories[j].values[i] - min_values[j]) / max_values[j]
			line_points.append(center + polyline[j] * value * distance)
		var value = (stat_categories[0].values[i] - min_values[0]) / max_values[0]
		line_points.append(center + polyline[-1] * value * distance)
		draw_polyline(line_points, stat_colors[i], 3, true)


func get_polyline(center: Vector2, radius: float) -> Array[Vector2]:
	var nb_categories: int = len(stat_categories)
	var points: Array[Vector2] = []
	var angle_step: float = 2 * PI / nb_categories
	var start_angle: float = atan2(radius * sin(angle_step), radius * (cos(angle_step)-1))
	
	# calculate points positions
	for i in range(nb_categories):
		var angle: float = i * angle_step + start_angle
		points.append(Vector2(
			center.x + radius * cos(angle),
			center.y + radius * sin(angle)))
	points.append(points[0])
	
	return points
