class_name HorrorManager
extends Node

var triggered_events: Array[int] = []

@onready var main_light: DirectionalLight3D = $"../../DirectionalLight3D"

var original_energy: float = 1.0

func trigger_horror(threshold: int) -> void:

	print("========================")
	print("HORROR EVENT DIPICU")
	print("Sanity threshold :", threshold)
	print("========================")

	match threshold:

		70:
			_horror_event_1()

		50:
			_horror_event_2()

		30:
			_horror_event_3()


func _horror_event_1() -> void:
	print("========================")
	print("HORROR EVENT 1")
	print("Lampu mulai berkedip...")
	print("========================")

	if main_light == null:
		print("DirectionalLight3D tidak ditemukan.")
		return

	for i in range(4):

		main_light.light_energy = 0.1
		await get_tree().create_timer(0.12).timeout

		main_light.light_energy = original_energy
		await get_tree().create_timer(0.15).timeout

	main_light.light_energy = original_energy

	print("Horror Event 1 selesai.")
	


func _horror_event_2() -> void:
	print("HORROR EVENT 2")
	print("Ada sesuatu yang mulai tidak beres...")


func _horror_event_3() -> void:
	print("HORROR EVENT 3")
	print("Ingatan buruk mulai muncul...")
