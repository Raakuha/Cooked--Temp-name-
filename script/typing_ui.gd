extends Control
class_name TypingUI

@onready var prompt_panel: PanelContainer = $PromptPanel

@onready var target_word_label: Label = \
	$PromptPanel/MarginContainer/VBoxContainer/Target_WordLabel

@onready var fill_word_label: Label = \
	$PromptPanel/MarginContainer/VBoxContainer/Fill_wordLabel

@onready var mistake_label: Label = \
	$PromptPanel/MarginContainer/VBoxContainer/MistakeLabel


@export var camera: Camera3D

var world_target: Vector3
var has_world_target: bool = false
var typing_active: bool = false


func _ready() -> void:
	prompt_panel.hide()


func _on_typing_manager_typing_started(target_word: String) -> void:
	typing_active = true

	target_word_label.text = "Target: " + target_word

	prompt_panel.show()


func _on_typing_manager_typing_updated(
	target_word: String,
	fill_word: String,
	mistake_count: int,
	last_input_correct: bool
) -> void:

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


func _on_typing_manager_typing_completed(_command: String) -> void:
	typing_active = false
	prompt_panel.hide()


func set_world_target(target_position: Vector3) -> void:
	world_target = target_position
	has_world_target = true


func clear_world_target() -> void:
	has_world_target = false
	prompt_panel.hide()


func _process(_delta: float) -> void:
	if not has_world_target:
		return

	if not typing_active:
		return

	if camera == null:
		return

	if camera.is_position_behind(world_target):
		prompt_panel.hide()
		return

	prompt_panel.show()

	var screen_position: Vector2 = camera.unproject_position(world_target)

	prompt_panel.position = (
		screen_position - prompt_panel.size / 2.0
	)
