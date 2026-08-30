extends Node
class_name MenuDeadlineTimer


signal deadline_started(recipe_id: String, duration: float)

signal deadline_expired


@export var cooking_sequence_manager: CookingSequenceManager

var _time_left: float = 0.0
var _running: bool = false
var _expired: bool = false
var _recipe_id: String = ""

@onready var tick_sound: AudioStreamPlayer = $TickSound

var _tick_accumulator: float = 0.0

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
	_tick_accumulator = 0.0
	set_process(true)
	deadline_started.emit("", _time_left)

func stop_order() -> void:
	_running = false
	_tick_accumulator = 0.0
	set_process(false)

	if tick_sound != null:
		tick_sound.stop()

func _process(delta: float) -> void:
	if not _running or _expired:
		return

	_time_left -= delta
	if _time_left > 0.0:

		var tick_interval: float

		if _time_left > 10.0:
			tick_interval = 1.0
		elif _time_left > 5.0:
			tick_interval = 0.7
		elif _time_left > 3.0:
			tick_interval = 0.45
		else:
			tick_interval = 0.2

		_tick_accumulator += delta

		if _tick_accumulator >= tick_interval:
			_tick_accumulator = 0.0

			if tick_sound != null:
				tick_sound.play()


	if _time_left <= 0.0:
		_time_left = 0.0
		_expired = true
		_running = false
		set_process(false)
		print("[MenuDeadlineTimer] DEADLINE ORDER HABIS")
		if tick_sound != null:
			tick_sound.stop()
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
