extends Node
class_name MenuDeadlineTimer


signal deadline_started(recipe_id: String, duration: float)

signal deadline_expired



## Deadline default (detik) kalau recipe_id tidak ada di RecipeData.DEADLINES.


@export var cooking_sequence_manager: CookingSequenceManager

var _time_left: float = 0.0
var _running: bool = false
var _expired: bool = false
var _recipe_id: String = ""


func _ready() -> void:
	set_process(false)

	if cooking_sequence_manager == null:
		push_warning(
			"MenuDeadlineTimer: cooking_sequence_manager belum dipasang."
		)
		return


func start_order(total_duration: float) -> void:
	_time_left = total_duration
	_running = true
	_expired = false
	_recipe_id = ""
	set_process(true)
	deadline_started.emit("", _time_left)

func stop_order() -> void:
	_running = false
	set_process(false)

	print("[MenuDeadlineTimer] ORDER TIMER STOP")


func _process(delta: float) -> void:
	if not _running or _expired:
		return

	_time_left -= delta

	if _time_left <= 0.0:
		_time_left = 0.0
		_expired = true
		_running = false
		set_process(false)
		print("[MenuDeadlineTimer] DEADLINE ORDER HABIS")
		deadline_expired.emit()
		

func get_deadline_for(recipe_id: String) -> float:
	return RecipeData.DEADLINES.get(recipe_id)


func is_expired() -> bool:
	return _expired
	


func is_running() -> bool:
	return _running

func get_remaining_time() -> float:
	return _time_left


func get_recipe_id() -> String:
	return _recipe_id
