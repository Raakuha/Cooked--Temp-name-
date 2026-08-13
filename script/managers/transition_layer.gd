class_name TransitionLayer
extends CanvasLayer

@onready var fade_rect: ColorRect = $ColorRect

var is_transitioning: bool = false


func _ready() -> void:
	fade_rect.color = Color.BLACK
	fade_rect.modulate.a = 0.0
	
	print("========================")
	print("TRANSITION LAYER READY")
	print("========================")


func fade_out(duration: float = 0.5) -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	
	var tween = create_tween()
	
	tween.tween_property(
		fade_rect,
		"modulate:a",
		1.0,
		duration
	)
	
	await tween.finished
	
	is_transitioning = false
	
	print("FADE OUT SELESAI")


func fade_in(duration: float = 0.5) -> void:
	if is_transitioning:
		return
	
	is_transitioning = true
	
	var tween = create_tween()
	
	tween.tween_property(
		fade_rect,
		"modulate:a",
		0.0,
		duration
	)
	
	await tween.finished
	
	is_transitioning = false
	
	print("FADE IN SELESAI")


func fade_to_black(duration: float = 0.5) -> void:
	await fade_out(duration)


func fade_from_black(duration: float = 0.5) -> void:
	await fade_in(duration)
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		print("TEST FADE OUT")
		fade_out()

	if event.is_action_pressed("ui_cancel"):
		print("TEST FADE IN")
		fade_in()
