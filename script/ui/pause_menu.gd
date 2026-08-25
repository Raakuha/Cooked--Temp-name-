extends Control

var  pause_toggle := false
@onready var cooking_sequence_manager: CookingSequenceManager = $"../../../Managers/CookingSequenceManager"
@onready var game_manager: GameManager = $"../../../Managers/GameManager"
@onready var restart: Button = $VBoxContainer/Restart
@onready var resume: Button = $VBoxContainer/Resume
@onready var quit: Button = $VBoxContainer/Quit
@onready var dialogue_bubble: DialogueBubble = $"../../DialogueBubble"

var dialogue_bubble_was_visible := false
var bubble_dialog_was_visible := false
var fullscreen_dialog_was_visible := false

func _ready() -> void:
	self.visible = false
	z_index = 100
	self.visible = false
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		pause_and_unpause()

func pause_and_unpause():
	pause_toggle = !pause_toggle
	get_tree().paused = pause_toggle
	self.visible = pause_toggle
	
	if pause_toggle:
		restart.disabled = not cooking_sequence_manager.active
		if dialogue_bubble != null:
			bubble_dialog_was_visible = (
				dialogue_bubble.get_node("Control/BubbleDialog").visible
			)

			fullscreen_dialog_was_visible = (
				dialogue_bubble.get_node("Control/FullscreenDialog").visible
			)

			# Sembunyikan sementara selama pause.
			dialogue_bubble.get_node("Control/BubbleDialog").hide()
			dialogue_bubble.get_node("Control/FullscreenDialog").hide()

		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		if dialogue_bubble != null:
			dialogue_bubble.get_node(
				"Control/BubbleDialog"
			).visible = bubble_dialog_was_visible

			dialogue_bubble.get_node(
				"Control/FullscreenDialog"
			).visible = fullscreen_dialog_was_visible
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_restart_pressed() -> void:
	if cooking_sequence_manager.active == false:
		return
	
	pause_and_unpause()
	if cooking_sequence_manager.active == true:
		cooking_sequence_manager.restart_current_recipe()
		game_manager.restart_current_order_timer()
	


func _on_resume_pressed() -> void:
	pause_and_unpause()


func _on_quit_pressed() -> void:
	get_tree().quit()
