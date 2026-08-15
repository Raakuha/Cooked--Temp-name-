extends CanvasLayer
class_name ItemPickUI

## R-P3-10 extension --- Tampilan untuk ItemPickManager. Nunjukkin SEMUA
## nama barang di workstation sekaligus (mode "pick"), atau 1 target aja
## waktu naruh balik barang yang salah diambil (mode "return"). Gaya
## visual disamain sama TypingUI (highlight huruf yang udah diketik,
## shake + flash merah pas salah) biar konsisten se-game.
##
## CATATAN: matched_len yang dikirim ItemPickManager itu posisi di LABEL
## TANPA SPASI (lihat ItemPickManager.strip_label()). _render_row() yang
## nerjemahin balik ke posisi di label ASLI (yang ada spasinya) buat
## ditampilin, lewat _visual_length().

@export var item_pick_manager: ItemPickManager

@onready var panel: PanelContainer = $PanelContainer
@onready var title_label: Label = \
	$PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var list_container: VBoxContainer = \
	$PanelContainer/MarginContainer/VBoxContainer/ListContainer

var _row_labels: Dictionary = {}  # item_id -> RichTextLabel

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
	title_label.text = "AMBIL BARANG YANG DIBUTUHKAN (ENTER = konfirmasi)"
	_rebuild_rows(candidates)
	panel.show()


func _on_pick_confirm_rejected() -> void:
	# ENTER ditekan tapi ketikan belum PAS sama barang manapun -- ini
	# tetap dianggap kesalahan, kasih feedback yang sama kayak salah ketik.
	title_label.text = "BELUM LENGKAP -- lanjut ketik atau ENTER lagi"
	play_error_feedback()


func _rebuild_rows(candidates: Array) -> void:
	for child in list_container.get_children():
		child.queue_free()

	_row_labels.clear()

	for candidate in candidates:
		var row := _make_row()
		list_container.add_child(row)
		_row_labels[candidate["item_id"]] = row


func _on_pick_updated(states: Array) -> void:
	var any_mistake := false

	for state in states:
		var row: RichTextLabel = _row_labels.get(state["item_id"])

		if row == null:
			continue

		_render_row(row, state["label"], state["matched_len"])

		if state["had_mistake"]:
			any_mistake = true

	if any_mistake:
		play_error_feedback()


func _on_pick_completed(_result: Dictionary) -> void:
	panel.hide()


# ------------------------------------------------------------------
# Mode EXIT WAIT -- barang udah benar, nunggu BACKSPACE buat lanjut.
# ------------------------------------------------------------------

func _on_exit_wait_started(label: String) -> void:
	title_label.text = "OK: " + label + " -- Tekan BACKSPACE untuk lanjut"
	_rebuild_rows([{"item_id": "_exit", "label": label}])
	_render_row(
		_row_labels["_exit"], label, ItemPickManager.strip_label(label).length()
	)
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
	var row: RichTextLabel = _row_labels.get("_return")

	if row == null:
		return

	_render_row(row, target, matched_len)

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


# ------------------------------------------------------------------
# Helper
# ------------------------------------------------------------------

func _make_row() -> RichTextLabel:
	var row := RichTextLabel.new()
	row.bbcode_enabled = true
	row.fit_content = true
	row.scroll_active = false
	row.autowrap_mode = TextServer.AUTOWRAP_OFF
	row.custom_minimum_size = Vector2(340, 28)
	return row


## stripped_matched_len = posisi di label TANPA SPASI (dari
## ItemPickManager). Fungsi ini nerjemahin balik ke posisi di label ASLI
## (yang ada spasinya) -- spasi otomatis ikut "selesai" begitu huruf
## sebelum & sesudahnya udah kena, jadi highlight-nya tetep mulus.
static func _visual_length(label: String, stripped_matched_len: int) -> int:
	if stripped_matched_len <= 0:
		return 0

	var seen := 0

	for i in label.length():
		if label[i] != " ":
			seen += 1

			if seen == stripped_matched_len:
				return i + 1

	return label.length()


func _render_row(row: RichTextLabel, label: String, stripped_matched_len: int) -> void:
	var visual_len: int = _visual_length(label, stripped_matched_len)
	var clamped_len: int = clamp(visual_len, 0, label.length())
	var completed := label.substr(0, clamped_len)
	var remaining := label.substr(clamped_len)

	row.text = (
		"[color=#FFFFFFFF][b]"
		+ completed
		+ "[/b][/color]"
		+ "[color=#FFFFFF55]"
		+ remaining
		+ "[/color]"
	)
