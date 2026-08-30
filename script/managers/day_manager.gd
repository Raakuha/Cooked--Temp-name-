class_name DayManager
extends Node

signal day_started(day: int)
signal day_completed(day: int)
signal game_completed

var current_day: int = 1
var total_days: int = 7

@export var music_manager: MusicManager
func start_day(day: int) -> void:
	current_day = day
	print("[DAY] music_manager = ", music_manager)
	if music_manager != null:
		if current_day == 7:
			music_manager.stop_music()
		else:
			music_manager.play_day_music()
	print("========================")
	print("DAY ", current_day, " START")
	print("========================")

	day_started.emit(current_day)


func complete_day() -> void:
	print("========================")
	print("DAY ", current_day, " COMPLETE")
	print("========================")

	day_completed.emit(current_day)


func next_day() -> void:
	if current_day >= total_days:
		print("========================")
		print("GAME COMPLETED")
		print("========================")

		game_completed.emit()
		return

	current_day += 1

	start_day(current_day)


func get_current_day() -> int:
	return current_day
