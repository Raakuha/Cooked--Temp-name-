extends CanvasLayer
class_name ItemPickUI


@export var row_scene: PackedScene
@export var item_pick_manager: ItemPickManager

@onready var panel: PanelContainer = $PanelContainer
@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/Header/TitleLabel
@onready var list_container: VBoxContainer = \
	$PanelContainer/MarginContainer/VBoxContainer/ListContainer
var _picked_item_ids: Dictionary = {}
var _row_labels: Dictionary = {}  # item_id -> RichTextLabel
var _current_candidates: Array = []
var shake_tween: Tween
var error_color_tween: Tween
var _panel_base_position: Vector2


func _ready() -> void:
	panel.hide()
	_panel_base_position = panel.position

	if item_pick_manager == null:
		return

	item_pick_manager.pick_started.connect(_on_pick_started)
	item_pick_manager.pick_updated.connect(_on_pick_updated)
	item_pick_manager.pick_completed.connect(_on_pick_completed)
	item_pick_manager.pick_confirm_rejected.connect(_on_pick_confirm_rejected)

	item_pick_manager.return_started.connect(_on_return_started)
	item_pick_manager.return_updated.connect(_on_return_updated)
	item_pick_manager.return_completed.connect(_on_return_completed)

	item_pick_manager.exit_wait_started.connect(_on_exit_wait_started)
	item_pick_manager.exit_wait_completed.connect(_on_exit_wait_completed)


# ------------------------------------------------------------------
# Mode PICK -- semua nama barang tampil sekaligus.
# ------------------------------------------------------------------

func _on_pick_started(candidates: Array) -> void:
	_picked_item_ids.clear()
	_current_candidates = candidates.duplicate(true)
	_rebuild_rows(candidates)
	panel.show()


func _on_pick_confirm_rejected() -> void:
	# ENTER ditekan tapi ketikan belum PAS sama barang manapun -- ini
	# tetap dianggap kesalahan, kasih feedback yang sama kayak salah ketik.
	title_label.text = "BELUM LENGKAP "
	play_error_feedback()


func _rebuild_rows(candidates: Array) -> void:
	for child in list_container.get_children():
		child.queue_free()

	_row_labels.clear()

	for candidate in candidates:
		var row : ItemPickRow = row_scene.instantiate()
		list_container.add_child(row)
		_row_labels[candidate["item_id"]] = row
		row.set_pending()
		row.set_item_label(candidate["label"], 0)


func _on_pick_updated(states: Array) -> void:
	var any_mistake := false

	for state in states:
		var row: ItemPickRow = _row_labels.get(
			state["item_id"]
		)

		if row == null:
			continue

		row.set_item_label(
			state["label"],
			state["matched_len"]
		)

		if state["had_mistake"]:
			any_mistake = true

	if any_mistake:
		play_error_feedback()

func _on_pick_completed(result: Dictionary) -> void:
	var  item_id : String = result.get("item_id", "")
	var row: ItemPickRow = _row_labels.get(item_id)
	if item_id != "":
		_picked_item_ids[item_id] = true

	if row != null:
		row.set_completed()

	panel.hide()
# ------------------------------------------------------------------
# Mode EXIT WAIT -- barang udah benar, nunggu BACKSPACE buat lanjut.
# ------------------------------------------------------------------

func _on_exit_wait_started(_label: String) -> void:
	title_label.text = "AMBIL BARANG"

	_rebuild_rows(_current_candidates)

	for item_id in _picked_item_ids:
		var row: ItemPickRow = _row_labels.get(item_id)

		if row != null:
			row.set_completed()

	panel.show()
func _on_exit_wait_completed() -> void:
	panel.hide()


# ------------------------------------------------------------------
# Mode RETURN -- naruh balik barang yang salah diambil.
# ------------------------------------------------------------------

func _on_return_started(label: String) -> void:
	title_label.text = "TARUH BALIK: " + label
	_rebuild_rows([{"item_id": "_return", "label": label}])
	panel.show()


func _on_return_updated(matched_len: int, target: String, had_mistake: bool) -> void:
	var row: ItemPickRow = _row_labels.get("_return")

	if row == null:
		return

	row.set_item_label(
		target,
		matched_len
	)

	if had_mistake:
		play_error_feedback()

func _on_return_completed(_label: String) -> void:
	panel.hide()


# ------------------------------------------------------------------
# Feedback salah -- shake + flash merah, gaya sama persis kayak TypingUI.
# ------------------------------------------------------------------

func play_error_feedback() -> void:
	if shake_tween != null:
		shake_tween.kill()

	if error_color_tween != null:
		error_color_tween.kill()

	panel.modulate = Color.WHITE

	error_color_tween = create_tween()

	error_color_tween.tween_property(
		panel, "modulate", Color(1.0, 0.2, 0.2, 1.0), 0.08
	)

	error_color_tween.tween_property(
		panel, "modulate", Color.WHITE, 0.18
	)

	panel.position = _panel_base_position

	shake_tween = create_tween()

	shake_tween.tween_property(
		panel, "position:x", _panel_base_position.x + 10.0, 0.04
	)

	shake_tween.tween_property(
		panel, "position:x", _panel_base_position.x - 10.0, 0.04
	)

	shake_tween.tween_property(
		panel, "position:x", _panel_base_position.x + 7.0, 0.04
	)

	shake_tween.tween_property(
		panel, "position:x", _panel_base_position.x - 7.0, 0.04
	)

	shake_tween.tween_property(
		panel, "position:x", _panel_base_position.x, 0.04
	)
