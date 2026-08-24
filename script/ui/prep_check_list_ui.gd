extends Control
class_name PrepChecklistUI

@export var cooking_sequence_manager: CookingSequenceManager
@export var item_pick_manager: ItemPickManager

@onready var panel: PanelContainer = $PanelContainer
@onready var title: Label = $PanelContainer/MarginContainer/VBoxContainer/Title
@onready var list_container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ListContainer

@export var item_labels: Dictionary = {}
@export var  title_text : String = "PREPARATION"
@export_range (12,8, 1) var title_font_size : int = 22
@export var completed_color :Color = Color(0.6, 1.0, 0.6, 1.0)
var pending_color : Color = Color.ALICE_BLUE
@export_range(0, 20, 1) var item_separation: int = 6

var _row_labels: Dictionary = {}  # checklist_id -> Label
var _has_active_checklist: bool = false


func _ready() -> void:
	
	panel.hide()
	
	title.text = title_text
	title.add_theme_font_size_override("font_size", title_font_size)
	
	list_container.add_theme_constant_override("separation", item_separation)
	

	if cooking_sequence_manager != null:
		cooking_sequence_manager.checklist_updated.connect(_on_checklist_updated)
		cooking_sequence_manager.cooking_unlocked.connect(_on_cooking_unlocked)

	if item_pick_manager != null:
		item_pick_manager.pick_started.connect(_on_item_pick_started)
		item_pick_manager.pick_completed.connect(_on_item_pick_completed)

	for workstation in get_tree().get_nodes_in_group("workstations"):
		if workstation.has_signal("action_completed"):
			if not workstation.action_completed.is_connected(_on_workstation_action_completed):
				workstation.action_completed.connect(_on_workstation_action_completed)




func register_label(checklist_id: String, display_name: String) -> void:
	item_labels[checklist_id] = display_name


func _on_checklist_updated(checklist: Dictionary) -> void:
	_has_active_checklist = not checklist.is_empty()

	_rebuild_rows(checklist)

	if _has_active_checklist:
		panel.show()
	else:
		panel.hide()


func _on_cooking_unlocked() -> void:
	# Semua prep beres -- checklist gak relevan lagi buat fase cooking.
	_has_active_checklist = false
	panel.hide()


func _rebuild_rows(checklist: Dictionary) -> void:
	for child in list_container.get_children():
		child.queue_free()

	_row_labels.clear()

	for checklist_id in checklist.keys():
		var row := Label.new()
		row.add_theme_font_size_override("font_size", 16)
		list_container.add_child(row)
		_row_labels[checklist_id] = row
		_render_row(checklist_id, checklist[checklist_id])


func _render_row(checklist_id: String, done: bool) -> void:
	var row: Label = _row_labels.get(checklist_id)

	if row == null:
		return

	var display_name: String = item_labels.get(checklist_id, checklist_id)
	var mark := "[x]" if done else "[ ]"

	row.text = mark + " " + display_name
	if done:
		row.modulate = completed_color
	else:
		row.modulate = pending_color


func _on_item_pick_started(_candidates: Array) -> void:
	panel.hide()

func _on_item_pick_completed(_result: Dictionary) -> void:
	if _has_active_checklist:
		panel.show()


func _on_workstation_action_completed(_workstation, _action_name: String) -> void:
	if _has_active_checklist:
		panel.show()
