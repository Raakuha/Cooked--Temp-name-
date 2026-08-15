extends Control
class_name PrepLocationUI

## R-P3-10 extension --- visual buat PrepLocationPicker. Nunjukkin
## beberapa prompt lokasi kecil SEKALIGUS, masing-masing nempel di posisi
## PromptAnchor workstation-nya di dunia 3D -- mode WORLD sama persis
## kayak TypingUI (unproject_position + is_position_behind), cuma untuk
## banyak target sekaligus, bukan cuma 1.
##
## Font sengaja dibikin lebih kecil dari TypingUI (prompt aksi utama),
## soalnya ini cuma prompt SELEKSI lokasi, bukan tantangan mengetik utama.

@export var prep_location_picker: PrepLocationPicker
@export var camera: Camera3D

var _labels: Dictionary = {}          # workstation -> RichTextLabel
var _anchors: Dictionary = {}         # workstation -> Node3D
var _shake_offsets: Dictionary = {}   # workstation -> Vector2
var _shake_tweens: Dictionary = {}
var _flash_tweens: Dictionary = {}
var _active: bool = false


func _ready() -> void:
	if prep_location_picker == null:
		return

	prep_location_picker.location_prompt_started.connect(_on_started)
	prep_location_picker.location_prompt_updated.connect(_on_updated)
	prep_location_picker.location_prompt_cleared.connect(_on_cleared)


func _on_started(candidates: Array) -> void:
	_clear_labels()

	for candidate in candidates:
		var workstation: String = candidate["workstation"]
		var label := _make_label()

		add_child(label)

		_labels[workstation] = label
		_anchors[workstation] = candidate["anchor"]
		_shake_offsets[workstation] = Vector2.ZERO

	_active = true
	_render_all(candidates)


func _on_updated(states: Array) -> void:
	_render_all(states)

	for state in states:
		if state["had_mistake"]:
			_play_error_feedback(state["workstation"])


func _on_cleared() -> void:
	_active = false
	_clear_labels()


# R-P3-10 extension: matched_len yang dikirim PrepLocationPicker itu
# posisi di label TANPA SPASI. Fungsi ini nerjemahin balik ke posisi di
# label ASLI (ada spasinya) buat ditampilin -- pola sama persis kayak
# ItemPickUI._visual_length().
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


func _render_all(states: Array) -> void:
	for state in states:
		var label: RichTextLabel = _labels.get(state["workstation"])

		if label == null:
			continue

		var text: String = state["label"]
		var visual_len: int = _visual_length(text, state.get("matched_len", 0))
		var matched_len: int = clamp(visual_len, 0, text.length())
		var completed := text.substr(0, matched_len)
		var remaining := text.substr(matched_len)

		label.text = (
			"[center][color=#FFFFFFFF][b]"
			+ completed
			+ "[/b][/color][color=#FFFFFF88]"
			+ remaining
			+ "[/color][/center]"
		)


func _make_label() -> RichTextLabel:
	var label := RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.scroll_active = false
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.custom_minimum_size = Vector2(110, 22)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("normal_font_size", 14)  # lebih kecil dari TypingUI
	label.add_theme_font_size_override("bold_font_size", 14)
	return label


func _clear_labels() -> void:
	for workstation in _labels.keys():
		_labels[workstation].queue_free()

	_labels.clear()
	_anchors.clear()
	_shake_offsets.clear()


func _process(_delta: float) -> void:
	if not _active or camera == null:
		return

	for workstation in _labels.keys():
		var label: RichTextLabel = _labels[workstation]
		var anchor: Node3D = _anchors.get(workstation)

		if anchor == null:
			label.hide()
			continue

		if camera.is_position_behind(anchor.global_position):
			label.hide()
			continue

		label.show()

		var screen_position: Vector2 = camera.unproject_position(anchor.global_position)
		var offset: Vector2 = _shake_offsets.get(workstation, Vector2.ZERO)

		label.position = screen_position - label.size / 2.0 + offset


func _play_error_feedback(workstation: String) -> void:
	var label: RichTextLabel = _labels.get(workstation)

	if label == null:
		return

	if _shake_tweens.has(workstation) and _shake_tweens[workstation] != null:
		_shake_tweens[workstation].kill()

	if _flash_tweens.has(workstation) and _flash_tweens[workstation] != null:
		_flash_tweens[workstation].kill()

	label.modulate = Color.WHITE

	var flash_tween := create_tween()
	flash_tween.tween_property(label, "modulate", Color(1.0, 0.2, 0.2, 1.0), 0.08)
	flash_tween.tween_property(label, "modulate", Color.WHITE, 0.18)
	_flash_tweens[workstation] = flash_tween

	_shake_offsets[workstation] = Vector2.ZERO

	var shake_tween := create_tween()
	shake_tween.tween_method(_set_shake_x.bind(workstation), 0.0, 10.0, 0.04)
	shake_tween.tween_method(_set_shake_x.bind(workstation), 10.0, -10.0, 0.04)
	shake_tween.tween_method(_set_shake_x.bind(workstation), -10.0, 7.0, 0.04)
	shake_tween.tween_method(_set_shake_x.bind(workstation), 7.0, -7.0, 0.04)
	shake_tween.tween_method(_set_shake_x.bind(workstation), -7.0, 0.0, 0.04)
	_shake_tweens[workstation] = shake_tween


func _set_shake_x(x: float, workstation: String) -> void:
	_shake_offsets[workstation] = Vector2(x, 0.0)
