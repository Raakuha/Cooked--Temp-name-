class_name HorrorManager
extends Node


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
	print("HORROR EVENT 1")
	print("Sesuatu terasa sedikit aneh...")


func _horror_event_2() -> void:
	print("HORROR EVENT 2")
	print("Ada sesuatu yang mulai tidak beres...")


func _horror_event_3() -> void:
	print("HORROR EVENT 3")
	print("Ingatan buruk mulai muncul...")
