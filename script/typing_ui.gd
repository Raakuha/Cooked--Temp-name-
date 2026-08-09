extends Control



@onready var target_word_label: Label = $CenterContainer/VBoxContainer/Target_WordLabel
@onready var mistake_label: Label = $CenterContainer/VBoxContainer/MistakeLabel
@onready var fill_word_label: Label = $CenterContainer/VBoxContainer/Fill_wordLabel



func _ready() -> void:


	hide()

func _on_typing_manager_typing_started(target_word: String) -> void:
	show()
	target_word_label.text = "Target: " + target_word



func _on_typing_manager_typing_updated(target_word: String, fill_word: String, mistake_count: int, last_input_correct: bool) -> void:
	var remaining_letters: int = target_word.length() - fill_word.length()

	fill_word_label.text = (
		fill_word +
		"-".repeat(remaining_letters)
	)

	if last_input_correct:
		fill_word_label.modulate = Color.SKY_BLUE
	else:
		fill_word_label.modulate = Color.ORANGE_RED

	mistake_label.text = "Mistake: %d" % mistake_count



func _on_typing_manager_typing_completed(command: String) -> void:
	
	hide()
