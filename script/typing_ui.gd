extends Control
class_name TypingUI


enum DisplayMode {
	WORLD,
	SCREEN
}

var display_mode: DisplayMode = DisplayMode.WORLD
var error_color_tween: Tween
func use_world_mode() -> void:
	display_mode = DisplayMode.WORLD


func use_screen_mode() -> void:
	display_mode = DisplayMode.SCREEN

@onready var prompt_panel: PanelContainer = $PromptPanel
@onready var error_sound: AudioStreamPlayer = $ErrorSound


@onready var fill_word_label: RichTextLabel = $PromptPanel/MarginContainer/VBoxContainer/Fill_wordLabel


@export var camera: Camera3D

var world_target: Vector3
var has_world_target: bool = false
var typing_active: bool = false
var shake_offset: Vector2 = Vector2.ZERO
var shake_tween: Tween

func _ready() -> void:
	prompt_panel.hide()

	prompt_panel.custom_minimum_size = Vector2(360, 80)

	fill_word_label.bbcode_enabled = true
	fill_word_label.fit_content = true
	fill_word_label.scroll_active = false
	fill_word_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	fill_word_label.custom_minimum_size = Vector2(320, 60)


	
func _on_typing_manager_typing_started(_target_word: String) -> void:
	typing_active = true
	prompt_panel.show()

func _on_typing_manager_typing_updated(
	target_word: String,
	fill_word: String,
	_mistake_count: int,
	last_input_correct: bool
) -> void:

	var typed_length := fill_word.length()

	var completed := target_word.substr(
		0,
		typed_length
	)

	var remaining := target_word.substr(
		typed_length
	)

	fill_word_label.text = (
		"[center]"
		+ "[color=#FFFFFFFF][b]"
		+ completed
		+ "[/b][/color]"
		+ "[color=#FFFFFF55]"
		+ remaining
		+ "[/color]"
		+ "[/center]"
	)
	if not last_input_correct:
		play_error_feedback()
func play_error_feedback(target_control: Control = self) -> void:
	if error_sound != null:
		error_sound.play()
	if shake_tween != null:
		shake_tween.kill()
	if error_color_tween != null:
		error_color_tween.kill()

	# Flash merah pada target
	var target_label: CanvasItem = target_control

	error_color_tween = create_tween()

	error_color_tween.tween_property(
		target_label,
		"modulate",
		Color(1.0, 0.2, 0.2, 1.0),
		0.08
	)

	error_color_tween.tween_property(
		target_label,
		"modulate",
		Color.WHITE,
		0.18
	)

	# Kalau target adalah TypingUI, pakai shake_offset yang sudah ada
	if target_control == self:
		shake_offset = Vector2.ZERO

		shake_tween = create_tween()

		shake_tween.tween_property(
			self,
			"shake_offset:x",
			10.0,
			0.04
		)

		shake_tween.tween_property(
			self,
			"shake_offset:x",
			-10.0,
			0.04
		)

		shake_tween.tween_property(
			self,
			"shake_offset:x",
			7.0,
			0.04
		)

		shake_tween.tween_property(
			self,
			"shake_offset:x",
			-7.0,
			0.04
		)

		shake_tween.tween_property(
			self,
			"shake_offset:x",
			0.0,
			0.04
		)
func _on_typing_manager_typing_completed(_command: String) -> void:
	typing_active = false
	prompt_panel.hide()

func cancel() -> void:
	typing_active = false
	prompt_panel.hide()
	shake_offset = Vector2.ZERO

	if shake_tween != null:
		shake_tween.kill()

	if error_color_tween != null:
		error_color_tween.kill()

func set_world_target(target_position: Vector3) -> void:
	world_target = target_position
	has_world_target = true


func clear_world_target() -> void:
	has_world_target = false
	prompt_panel.hide()


func _process(_delta: float) -> void:
	if not typing_active:
		return

	if display_mode == DisplayMode.SCREEN:
		prompt_panel.show()

		var viewport_size := get_viewport().get_visible_rect().size

		prompt_panel.position = Vector2(
			(viewport_size.x - prompt_panel.size.x) / 2.0,
			viewport_size.y * 0.50 - prompt_panel.size.y / 2.0
		) + shake_offset

		return

	if not has_world_target:
		return

	if camera == null:
		return

	if camera.is_position_behind(world_target):
		prompt_panel.hide()
		return

	prompt_panel.show()

	var screen_position: Vector2 = camera.unproject_position(world_target)

	prompt_panel.position = (
		screen_position
		- prompt_panel.size / 2.0
		+ shake_offset
	)
