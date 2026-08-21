class_name EndingScreen
extends CanvasLayer

@onready var game_title: Label = $Control/GameTitle
@onready var credits: Label = $Control/Credits

func _ready() -> void:
	visible = false

	game_title.modulate.a = 0.0
	credits.modulate.a = 0.0

	print("========================")
	print("ENDING SCREEN READY")
	print("========================")


func show_ending() -> void:

	visible = true

	print("========================")
	print("ENDING SCREEN")
	print("========================")

	# Pastikan layar mulai dalam keadaan tersembunyi
	game_title.modulate.a = 0.0
	credits.modulate.a = 0.0

	# Munculkan judul
	print("ENDING TITLE SHOW")

	var tween_title := create_tween()

	tween_title.tween_property(
		game_title,
		"modulate:a",
		1.0,
		2.0
	)

	await tween_title.finished

	# Tunggu sebentar
	await get_tree().create_timer(1.0).timeout

	# Munculkan credit
	print("ENDING CREDITS SHOW")

	var tween_credits := create_tween()

	tween_credits.tween_property(
		credits,
		"modulate:a",
		1.0,
		2.0
	)

	await tween_credits.finished

	print("========================")
	print("ENDING SCREEN COMPLETE")
	print("========================")
