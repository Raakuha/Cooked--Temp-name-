extends Control

var  pause_toggle := false
@onready var cooking_sequence_manager: CookingSequenceManager = $"../../../Managers/CookingSequenceManager"
@onready var game_manager: GameManager = $"../../../Managers/GameManager"
@onready var restart: Button = $VBoxContainer/Restart
@onready var resume: Button = $VBoxContainer/Resume
@onready var quit: Button = $VBoxContainer/Quit
@onready var dialogue_bubble: DialogueBubble = $"../../DialogueBubble"
@onready var item_pick_ui: ItemPickUI = $"../../ItemPickUI"
@onready var game_hud: GameHUD = $"../../GameHUD"
@onready var prep_checklist_ui: PrepChecklistUI = $"../../PrepCheckListUI"
@onready var texture_button: TextureButton = $"../Pause_button/TextureButton"
var button_tween: Tween
var game_hud_was_visible := false
var prep_checklist_was_visible := false
var dialogue_bubble_was_visible := false
var bubble_dialog_was_visible := false
var fullscreen_dialog_was_visible := false
var item_pick_ui_was_visible := false
var  textbutton_was_visible := false
func _ready() -> void:
	self.visible = false
	z_index = 100
	texture_button.visible = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	texture_button.pivot_offset = texture_button.size / 2.0
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		pause_and_unpause()
		

func pause_and_unpause():
	pause_toggle = !pause_toggle
	
	texture_button.button_pressed = pause_toggle
	animate_pause_button()
	get_tree().paused = pause_toggle
	self.visible = pause_toggle
	
	if pause_toggle:
		restart.disabled = not cooking_sequence_manager.active
		
		
		if game_hud != null:
			game_hud_was_visible = game_hud.visible
			game_hud.hide()
			
		if prep_checklist_ui != null:
			prep_checklist_was_visible = prep_checklist_ui.visible
			prep_checklist_ui.hide()
		
		if dialogue_bubble != null:
			bubble_dialog_was_visible = (
				dialogue_bubble.get_node("Control/BubbleDialog").visible
			)

			fullscreen_dialog_was_visible = (
				dialogue_bubble.get_node("Control/FullscreenDialog").visible
			)
			
			dialogue_bubble.get_node("Control/BubbleDialog").hide()
			dialogue_bubble.get_node("Control/FullscreenDialog").hide()
		if item_pick_ui != null:
			item_pick_ui_was_visible = item_pick_ui.panel.visible
			item_pick_ui.panel.hide()

		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	else:
		
		if game_hud != null:
			game_hud.visible = game_hud_was_visible
		
		if prep_checklist_ui != null:
			prep_checklist_ui.visible = prep_checklist_was_visible

		if dialogue_bubble != null:
			dialogue_bubble.get_node(
				"Control/BubbleDialog"
			).visible = bubble_dialog_was_visible

			dialogue_bubble.get_node(
				"Control/FullscreenDialog"
			).visible = fullscreen_dialog_was_visible
		if item_pick_ui != null:
			item_pick_ui.panel.visible = item_pick_ui_was_visible
			
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_restart_pressed() -> void:
	if cooking_sequence_manager.active == false:
		return
	if item_pick_ui != null:
		item_pick_ui_was_visible = item_pick_ui.panel.visible
		item_pick_ui.panel.hide()

	pause_and_unpause()
	if cooking_sequence_manager.active == true:
		cooking_sequence_manager.restart_current_recipe()
		game_manager.restart_current_order_timer()
	

func animate_pause_button() -> void:
	if texture_button == null:
		return

	if button_tween != null:
		button_tween.kill()

	button_tween = create_tween()

	texture_button.scale = Vector2.ONE

	button_tween.tween_property(
		texture_button,
		"scale",
		Vector2(0.85, 0.85),
		0.06
	)

	button_tween.tween_property(
		texture_button,
		"scale",
		Vector2(1.05, 1.05),
		0.08
	)

	button_tween.tween_property(
		texture_button,
		"scale",
		Vector2.ONE,
		0.06
	)
func _on_resume_pressed() -> void:
	pause_and_unpause()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_texture_button_pressed() -> void:
	pause_and_unpause()
