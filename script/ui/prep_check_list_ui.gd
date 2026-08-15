extends CanvasLayer
class_name PrepChecklistUI

## R-P3-10 --- Overview checklist prep resep aktif ("Nasi [ ], Daging [x],
## ..."). Baca langsung dari CookingSequenceManager.checklist_updated,
## gak nyimpen state sendiri.
##
## Sembunyi otomatis pas ItemPickManager lagi nunjukkin daftar barang di 1
## workstation (biar gak numpuk 2 list bareng), muncul lagi begitu action
## di workstation itu kelar (action_completed, dari grup "workstations" --
## pola yang sama kayak CookingSequenceManager dengerin timing_result).
##
## Nama tampilan tiap checklist_id diambil dari `item_labels` (isi manual
## lewat Inspector atau register_label()) -- kalau belum diisi, checklist_id
## mentah yang ditampilin (fallback aman, gak nge-crash).
##
## FIX bug "Node not found: PanelContainer" --- sebelumnya UI ini nunggu
## PanelContainer/MarginContainer/VBoxContainer udah ada duluan sebagai
## child manual di scene (gak pernah dibikin, makanya crash). Sekarang
## dia BIKIN SENDIRI hierarchy-nya lewat kode di _ready(), pola yang sama
## kayak PrepLocationUI dan ItemPickUI -- gak butuh apa-apa dari scene
## selain node CanvasLayer kosong + script ini nempel di situ.

@export var cooking_sequence_manager: CookingSequenceManager
@export var item_pick_manager: ItemPickManager

var panel: PanelContainer
var list_container: VBoxContainer

# checklist_id -> nama tampilan, mis. {"daging": "Daging Cincang"}.
@export var item_labels: Dictionary = {}

var _row_labels: Dictionary = {}  # checklist_id -> Label
var _has_active_checklist: bool = false


func _ready() -> void:
	_build_ui()
	panel.hide()

	if cooking_sequence_manager != null:
		cooking_sequence_manager.checklist_updated.connect(_on_checklist_updated)
		cooking_sequence_manager.cooking_unlocked.connect(_on_cooking_unlocked)

	if item_pick_manager != null:
		item_pick_manager.pick_started.connect(_on_item_pick_started)

	for workstation in get_tree().get_nodes_in_group("workstations"):
		if workstation.has_signal("action_completed"):
			if not workstation.action_completed.is_connected(_on_workstation_action_completed):
				workstation.action_completed.connect(_on_workstation_action_completed)


# Bikin PanelContainer > MarginContainer > VBoxContainer lewat kode,
# nempel pojok kiri atas layar. Dipanggil sekali di _ready(), sebelum
# apapun yang butuh `panel`/`list_container`.
func _build_ui() -> void:
	panel = PanelContainer.new()
	panel.name = "PanelContainer"

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0, 0, 0, 0.4)
	panel.add_theme_stylebox_override("panel", panel_style)

	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.position = Vector2(16, 16)

	add_child(panel)

	var margin := MarginContainer.new()
	margin.name = "MarginContainer"
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	list_container = VBoxContainer.new()
	list_container.name = "VBoxContainer"
	list_container.add_theme_constant_override("separation", 4)
	margin.add_child(list_container)


func register_label(checklist_id: String, display_name: String) -> void:
	item_labels[checklist_id] = display_name


func _on_checklist_updated(checklist: Dictionary) -> void:
	_has_active_checklist = not checklist.is_empty()

	_rebuild_rows(checklist)

	if _has_active_checklist:
		panel.show()


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
	row.modulate = Color(0.6, 1.0, 0.6) if done else Color.WHITE


# ------------------------------------------------------------------
# Sembunyi pas ItemPickUI nongol, muncul lagi pas action-nya kelar.
# ------------------------------------------------------------------

func _on_item_pick_started(_candidates: Array) -> void:
	panel.hide()


func _on_workstation_action_completed(_workstation, _action_name: String) -> void:
	if _has_active_checklist:
		panel.show()
