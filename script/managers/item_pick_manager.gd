extends Node
class_name ItemPickManager

signal pick_started(candidates: Array)
signal pick_updated(states: Array)  # Array of {item_id,label,matched_len,had_mistake}
signal pick_completed(result: Dictionary)  # {"item_id":String,"label":String}
signal pick_confirm_rejected()  # ENTER ditekan tapi buffer belum PAS 1 barang

signal return_started(label: String)
signal return_updated(matched_len: int, target: String, had_mistake: bool)
signal return_completed(label: String)

signal exit_wait_started(label: String)
signal exit_wait_completed()

var _candidates: Array = []
var _buffer: String = ""
var _picking: bool = false
var _cancel_requested: bool = false

var _return_target: String = ""
var _return_fill: String = ""
var _returning: bool = false

var _waiting_exit: bool = false


static func strip_label(label: String) -> String:
	return label.replace(" ", "")



func run_pick(candidates: Array) -> Dictionary:
	_candidates = candidates.duplicate(true)
	_buffer = ""
	_picking = true
	_cancel_requested = false

	pick_started.emit(_candidates.duplicate(true))
	_emit_pick_state()

	var result: Dictionary = await pick_completed
	return result

func cancel() -> void:
	_cancel_requested = true

	if _picking:

		_picking = false
		_buffer = ""

		pick_completed.emit({
			"cancelled": true
		})


	elif _returning:

		_returning = false
		_return_fill = ""

		return_completed.emit(_return_target)
	elif _waiting_exit:

		_waiting_exit = false

		exit_wait_completed.emit()

func run_return(label: String) -> bool:
	_return_target = label
	_return_fill = ""
	_returning = true
	_cancel_requested = false

	return_started.emit(label)
	return_updated.emit(0, _return_target, false)

	await return_completed
	
	var was_cancelled: bool = _cancel_requested

	_returning = false
	return was_cancelled


func wait_for_exit(label: String) -> bool:
	_waiting_exit = true
	_cancel_requested = false

	exit_wait_started.emit(label)

	await exit_wait_completed

	var was_cancelled: bool = _cancel_requested

	_waiting_exit = false

	return was_cancelled

func _confirm_exit() -> void:
	_waiting_exit = false
	exit_wait_completed.emit()



func _exit_while_picking() -> void:
	_picking = false

	pick_completed.emit({"exit": true})


func _unhandled_key_input(event: InputEvent) -> void:
	if not (_picking or _returning or _waiting_exit):
		return

	if not event is InputEventKey:
		return


	if event.is_action_pressed("item_pick_exit"):
		if _waiting_exit:
			_confirm_exit()
			get_viewport().set_input_as_handled()
		elif _picking:
			_exit_while_picking()
			get_viewport().set_input_as_handled()
		return

	
	if event.is_action_pressed("item_pick_confirm"):
		if _picking:
			_try_confirm_pick()
			get_viewport().set_input_as_handled()
		return

	var key := event as InputEventKey

	if not key.pressed or key.echo:
		return

	if key.unicode == 0:
		return

	var input := String.chr(key.unicode).to_upper()

	if not "ABCDEFGHIJKLMNOPQRSTUVWXYZ".contains(input):
		return

	if _picking:
		_check_pick(input)
	elif _returning:
		_check_return(input)

	get_viewport().set_input_as_handled()


func _check_pick(input: String) -> void:
	var next_buffer: String = _buffer + input

	var still_matching: Array = []

	for candidate in _candidates:
		var stripped: String = strip_label(candidate["label"])

		if stripped.length() >= next_buffer.length() \
			and stripped.substr(0, next_buffer.length()) == next_buffer:
			still_matching.append(candidate)

	if still_matching.is_empty():

		_emit_pick_state(true)
		return

	_buffer = next_buffer
	_emit_pick_state(false)



func _try_confirm_pick() -> void:
	for candidate in _candidates:
		if strip_label(candidate["label"]) == _buffer:
			_picking = false

			var result: Dictionary = {
				"item_id": candidate["item_id"],
				"label": candidate["label"]
			}

			pick_completed.emit(result)
			return


	pick_confirm_rejected.emit()


func _emit_pick_state(had_mistake: bool = false) -> void:
	var states: Array = []

	for candidate in _candidates:
		var label: String = candidate["label"]
		var stripped: String = strip_label(label)
		var prefix_len: int = min(_buffer.length(), stripped.length())
		var matched_len := 0

		if stripped.substr(0, prefix_len) == _buffer.substr(0, prefix_len):
			matched_len = _buffer.length()

		states.append({
			"item_id": candidate["item_id"],
			"label": label,
			"matched_len": matched_len,  # posisi di LABEL TANPA SPASI
			"had_mistake": had_mistake
		})

	pick_updated.emit(states)


func _check_return(input: String) -> void:
	var stripped_target: String = strip_label(_return_target)
	var next_len: int = _return_fill.length() + 1

	if next_len <= stripped_target.length() \
		and stripped_target.substr(next_len - 1, 1) == input:
		_return_fill += input
		return_updated.emit(_return_fill.length(), _return_target, false)

		if _return_fill.length() == stripped_target.length():
			_returning = false
			var finished := _return_target
			return_completed.emit(finished)
	else:
		return_updated.emit(_return_fill.length(), _return_target, true)
