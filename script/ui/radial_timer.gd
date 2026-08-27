extends Control
class_name RadialTimer

@export var radius: float = 72.0
@export var ring_width: float = 8.50

@export var background_color: Color = Color(0.12, 0.10, 0.09, 1.0)
@export var normal_color: Color = Color(0.82, 0.39, 0.10, 1.0)
@export var urgent_color: Color = Color(0.85, 0.08, 0.06, 1.0)

@export var warning_seconds: float = 15.0

var progress: float = 1.0
var remaining_time: float = 0.0
var total_time: float = 1.0


func set_timer(
	current_time: float,
	max_time: float
) -> void:
	remaining_time = max(current_time, 0.0)
	total_time = max(max_time, 0.01)

	progress = clamp(
		remaining_time / total_time,
		0.0,
		1.0
	)

	queue_redraw()


func set_warning_state(enabled: bool) -> void:
	queue_redraw()


func _draw() -> void:
	var center := size / 2.0

	# Background ring
	draw_arc(
		center,
		radius,
		0.0,
		TAU,
		96,
		background_color,
		ring_width,
		true
	)

	# Progress ring
	if progress <= 0.0:
		return

	var color := normal_color

	if remaining_time <= warning_seconds:
		color = urgent_color

	var start_angle := -PI / 2.0
	var end_angle := start_angle + (TAU * progress)

	draw_arc(
		center,
		radius,
		start_angle,
		end_angle,
		96,
		color,
		ring_width,
		true
	)
