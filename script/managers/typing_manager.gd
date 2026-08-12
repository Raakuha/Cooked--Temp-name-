extends Node

class_name TypingManager

signal typing_result(target_word: String, mistake_count: int)
signal typing_started(target_word : String)
signal typing_updated(
	target_word : String,
	fill_word : String,
	mistake_count : int,
	last_input_correct : bool
)
signal typing_completed (command : String)

var target : String = ""
var fill : String = ""
var mistake_count: int = 0
var active : bool = false

func start_typing(new_target : String)-> void:
	target = new_target.to_upper()
	fill = ""
	mistake_count = 0
	active = true
	typing_started.emit(target)
	typing_updated.emit(target, fill, mistake_count, true)


func _unhandled_key_input(event: InputEvent) -> void:
	if not active:
		return
	if not event is InputEventKey:
		return
	var key := event as InputEventKey

	if not key.pressed or key.echo:
		return

	if key.unicode == 0:
		return

	var input := String.chr(key.unicode).to_upper()

	if not "ABCDEFGHIJKLMNOPQRSTUVWXYZ".contains(input):
		return

	check(input)
	get_viewport().set_input_as_handled()

func check(input: String) -> void:
	var cur_index:= fill.length()
	
	while cur_index < target.length() and target.substr(cur_index, 1) == " ":
		fill += " "
		cur_index += 1
	var expected_char := target.substr(cur_index, 1)

	if input == expected_char:
		fill += input

		typing_updated.emit(
			target,
			fill,
			mistake_count,
			true
		)

		if fill.length() == target.length():
			finish_typing()
	else:
		mistake_count += 1
		typing_updated.emit(
			target,
			fill,
			mistake_count,
			false
		)

func finish_typing() -> void:
	active = false
	print("Target word sudah selesai " + target)

	typing_result.emit(target, mistake_count)
	typing_completed.emit(target)
