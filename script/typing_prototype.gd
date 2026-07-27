extends Control

signal typing_completed(command: String)


var target_word: String = "REFRIGERATOR"
var fill_word: String = ""
var sus : int = 0
var active: bool = true


@onready var target_word_label: Label = $CenterContainer/VBoxContainer/Target_WordLabel
@onready var fill_word_label: Label = $CenterContainer/VBoxContainer/Fill_wordLabel
@onready var suspicision_label: Label = $CenterContainer/VBoxContainer/SuspicisionLabel

func _unhandled_key_input(event: InputEvent) -> void:
	if not active:
		return
	if event is not InputEventKey:
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
	var cur_index:= fill_word.length()
	var expected_char := target_word.substr(cur_index, 1)
	
	if input == expected_char:
		fill_word += input
		fill_word_label.modulate = Color.SKY_BLUE
		if fill_word.length() == target_word.length():
			finish()
	else:
		sus += 1
		fill_word_label.modulate = Color.RED
	
	update_ui()
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	typing_completed.connect(_on_typing_completed)
	
	target_word = target_word.to_upper()
	update_ui()




func update_ui() -> void:
	var remain_letters := target_word.length() - fill_word.length()
	target_word_label.text = "Target = " + target_word
	fill_word_label.text = (
		fill_word +
		"_".repeat(remain_letters)
	)
	suspicision_label.text = "Suspicion : %d" % sus

func finish() -> void:
	active = false
	print("Typing selesai wak: ", target_word)
	typing_completed.emit(target_word)
	
func _on_typing_completed(command: String) -> void:
	print("Sinyal diterima, perintah terseksekusi ! berarti ke ", command)
	

	
