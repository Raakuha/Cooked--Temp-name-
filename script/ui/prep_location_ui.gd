extends Control
class_name PrepLocationUI

## ================================================================
## PrepLocationUI
## ================================================================
## Visual UI untuk PrepLocationPicker.
##
## Menampilkan prompt lokasi seperti:
##   KULKAS
##   TEMPAT TELUR
##   TEMPAT BUMBU
##   WAJAN DATAR
##
## Setiap prompt ditempel pada posisi PromptAnchor workstation
## menggunakan Camera3D.unproject_position().
##
## Semua styling prompt dibuat editable dari Inspector:
## - Font size
## - Font color
## - Outline size
## - Outline color
## - Shadow
## - Shadow color
## - Shadow offset
##
## Behavior:
## - Banyak prompt bisa tampil sekaligus.
## - Prompt mengikuti posisi workstation di dunia 3D.
## - Prompt hilang kalau berada di belakang kamera.
## - Prompt disembunyikan sementara ketika ItemPickUI aktif.
## - Prompt kembali setelah action TAKE selesai.
## - Typo pada lokasi memberikan flash merah + shake.
## ================================================================


# ----------------------------------------------------------------
# REFERENCES
# ----------------------------------------------------------------

@export_category("References")

@export var prep_location_picker: PrepLocationPicker
@export var camera: Camera3D
@export var item_pick_manager: ItemPickManager


# ----------------------------------------------------------------
# PROMPT STYLE
# ----------------------------------------------------------------

@export_category("Prompt Style")

@export_range(12, 72, 1)
var prompt_font_size: int = 26

@export
var prompt_font_color: Color = Color.WHITE

@export_range(0, 16, 1)
var prompt_outline_size: int = 5

@export
var prompt_outline_color: Color = Color.BLACK

@export
var prompt_shadow_enabled: bool = true

@export
var prompt_shadow_color: Color = Color(0, 0, 0, 0.8)

@export
var prompt_shadow_offset: Vector2 = Vector2(2, 2)

@export_range(40, 500, 1)
var prompt_min_width: float = 180.0

@export_range(20, 150, 1)
var prompt_min_height: float = 40.0


# ----------------------------------------------------------------
# ERROR FEEDBACK
# ----------------------------------------------------------------

@export_category("Error Feedback")

@export_range(0.0, 30.0, 0.5)
var error_shake_distance: float = 10.0

@export
var error_flash_color: Color = Color(1.0, 0.2, 0.2, 1.0)

@export_range(0.01, 1.0, 0.01)
var error_flash_in_duration: float = 0.08

@export_range(0.01, 1.0, 0.01)
var error_flash_out_duration: float = 0.18


# ----------------------------------------------------------------
# INTERNAL STATE
# ----------------------------------------------------------------

var _labels: Dictionary = {}
# workstation -> RichTextLabel

var _anchors: Dictionary = {}
# workstation -> Node3D

var _shake_offsets: Dictionary = {}
# workstation -> Vector2

var _shake_tweens: Dictionary = {}
# workstation -> Tween

var _flash_tweens: Dictionary = {}
# workstation -> Tween

var _active: bool = false
var _hidden_for_item_pick: bool = false


# ----------------------------------------------------------------
# READY
# ----------------------------------------------------------------

func _ready() -> void:
	# Prompt UI harus berada di atas UI lain.
	z_index = 100

	# Label boleh berada di luar rect parent.
	clip_contents = false

	# ------------------------------------------------------------
	# PrepLocationPicker
	# ------------------------------------------------------------
	if prep_location_picker != null:
		prep_location_picker.location_prompt_started.connect(
			_on_started
		)

		prep_location_picker.location_prompt_updated.connect(
			_on_updated
		)

		prep_location_picker.location_prompt_cleared.connect(
			_on_cleared
		)
	else:
		push_warning(
			"[PrepLocationUI] PrepLocationPicker belum dipasang."
		)

	# ------------------------------------------------------------
	# ItemPickManager
	# ------------------------------------------------------------
	if item_pick_manager != null:
		item_pick_manager.pick_started.connect(
			_on_item_pick_started
		)
	else:
		push_warning(
			"[PrepLocationUI] ItemPickManager belum dipasang."
		)

	# ------------------------------------------------------------
	# Workstations
	# ------------------------------------------------------------
	_connect_workstations()


# ----------------------------------------------------------------
# WORKSTATION SIGNAL SETUP
# ----------------------------------------------------------------

func _connect_workstations() -> void:
	for workstation in get_tree().get_nodes_in_group("workstations"):
		if not workstation.has_signal("action_completed"):
			continue

		if not workstation.action_completed.is_connected(
			_on_workstation_action_completed
		):
			workstation.action_completed.connect(
				_on_workstation_action_completed
			)


# ----------------------------------------------------------------
# PREP LOCATION STARTED
# ----------------------------------------------------------------

func _on_started(candidates: Array) -> void:
	_clear_labels()

	for candidate in candidates:
		var workstation: String = candidate["workstation"]
		var anchor: Node3D = candidate["anchor"]

		var label := _make_label()

		# Pastikan setiap prompt berada di atas UI lain.
		label.z_index = 101

		add_child(label)

		_labels[workstation] = label
		_anchors[workstation] = anchor
		_shake_offsets[workstation] = Vector2.ZERO

	_active = true
	_hidden_for_item_pick = false

	_render_all(candidates)


# ----------------------------------------------------------------
# PREP LOCATION UPDATED
# ----------------------------------------------------------------

func _on_updated(states: Array) -> void:
	_render_all(states)

	for state in states:
		if state.get("had_mistake", false):
			_play_error_feedback(
				String(state["workstation"])
			)


# ----------------------------------------------------------------
# PREP LOCATION CLEARED
# ----------------------------------------------------------------

func _on_cleared() -> void:
	_active = false
	_hidden_for_item_pick = false

	_clear_labels()


# ----------------------------------------------------------------
# ITEM PICK STARTED
# ----------------------------------------------------------------

func _on_item_pick_started(_candidates: Array) -> void:
	# Prompt lokasi tetap ada di state PrepLocationPicker,
	# tetapi disembunyikan sementara secara visual.
	_hidden_for_item_pick = true


# ----------------------------------------------------------------
# WORKSTATION ACTION COMPLETED
# ----------------------------------------------------------------

func _on_workstation_action_completed(
	_workstation,
	_action_name: String
) -> void:
	# Setelah TAKE selesai, prompt lokasi boleh tampil lagi.
	_hidden_for_item_pick = false


# ----------------------------------------------------------------
# VISUAL LENGTH
# ----------------------------------------------------------------
## PrepLocationPicker menghitung matched_len tanpa spasi.
## Fungsi ini mengembalikan panjang visual berdasarkan label asli
## yang masih memiliki spasi.
##
## Contoh:
## "TEMPAT BUMBU"
## matched_len = 7
## visual = "TEMPAT "
##
## Jadi spasi tetap ditampilkan dengan benar.


static func _visual_length(
	label: String,
	stripped_matched_len: int
) -> int:
	if stripped_matched_len <= 0:
		return 0

	var seen := 0

	for i in label.length():
		if label[i] != " ":
			seen += 1

			if seen == stripped_matched_len:
				return i + 1

	return label.length()


# ----------------------------------------------------------------
# RENDER ALL PROMPTS
# ----------------------------------------------------------------

func _render_all(states: Array) -> void:
	var completed_color := prompt_font_color
	var remaining_color := prompt_font_color
	remaining_color.a =0.53
	var completed_hex := completed_color.to_html(true)
	var remaining_hex := remaining_color.to_html(true)
	for state in states:
		var workstation: String = state["workstation"]

		var label: RichTextLabel = _labels.get(
			workstation
		)

		if label == null:
			continue

		var text: String = String(
			state["label"]
		)

		var visual_len: int = _visual_length(
			text,
			int(state.get("matched_len", 0))
		)

		var matched_len: int = clamp(
			visual_len,
			0,
			text.length()
		)

		var completed := text.substr(
			0,
			matched_len
		)

		var remaining := text.substr(
			matched_len
		)

		# Bagian yang sudah diketik:
		# putih + bold
		#
		# Bagian yang belum diketik:
		# putih transparan

		label.text = (
			"[center]"
			+ "[color=#" + completed_hex + "][b]"
			+ completed
			+ "[/b][/color]"
			+ "[color=#" + remaining_hex + "]"
			+ remaining
			+ "[/color]"
			+ "[/center]"
		)

# ----------------------------------------------------------------
# CREATE LABEL
# ----------------------------------------------------------------

func _make_label() -> RichTextLabel:
	var label := RichTextLabel.new()

	# ------------------------------------------------------------
	# Basic setup
	# ------------------------------------------------------------

	label.bbcode_enabled = true
	label.fit_content = true
	label.scroll_active = false
	label.autowrap_mode = TextServer.AUTOWRAP_OFF

	label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	label.custom_minimum_size = Vector2(
		prompt_min_width,
		prompt_min_height
	)

	# ------------------------------------------------------------
	# Font
	# ------------------------------------------------------------

	label.add_theme_font_size_override(
		"normal_font_size",
		prompt_font_size
	)

	label.add_theme_font_size_override(
		"bold_font_size",
		prompt_font_size
	)

	# ------------------------------------------------------------
	# Font color
	# ------------------------------------------------------------

	label.add_theme_color_override(
		"default_color",
		prompt_font_color
	)

	# ------------------------------------------------------------
	# Outline
	# ------------------------------------------------------------

	label.add_theme_constant_override(
		"outline_size",
		prompt_outline_size
	)

	label.add_theme_color_override(
		"font_outline_color",
		prompt_outline_color
	)

	# ------------------------------------------------------------
	# Shadow
	# ------------------------------------------------------------

	if prompt_shadow_enabled:
		label.add_theme_color_override(
			"font_shadow_color",
			prompt_shadow_color
		)

		label.add_theme_constant_override(
			"shadow_offset_x",
			int(prompt_shadow_offset.x)
		)

		label.add_theme_constant_override(
			"shadow_offset_y",
			int(prompt_shadow_offset.y)
		)

	return label


# ----------------------------------------------------------------
# CLEAR LABELS
# ----------------------------------------------------------------

func _clear_labels() -> void:
	for workstation in _labels.keys():
		var label: RichTextLabel = _labels[workstation]

		if is_instance_valid(label):
			label.queue_free()

	_labels.clear()
	_anchors.clear()
	_shake_offsets.clear()


# ----------------------------------------------------------------
# PROCESS
# ----------------------------------------------------------------

func _process(_delta: float) -> void:
	if not _active:
		return

	if camera == null:
		return

	# ------------------------------------------------------------
	# Hide while ItemPickUI is active
	# ------------------------------------------------------------

	if _hidden_for_item_pick:
		for workstation in _labels.keys():
			var hidden_label: RichTextLabel = _labels[workstation]

			if is_instance_valid(hidden_label):
				hidden_label.hide()

		return

	# ------------------------------------------------------------
	# Position all workstation prompts
	# ------------------------------------------------------------

	for workstation in _labels.keys():
		var label: RichTextLabel = _labels[workstation]

		if not is_instance_valid(label):
			continue

		var anchor: Node3D = _anchors.get(
			workstation
		)

		if anchor == null or not is_instance_valid(anchor):
			label.hide()
			continue

		# --------------------------------------------------------
		# Behind camera
		# --------------------------------------------------------

		if camera.is_position_behind(
			anchor.global_position
		):
			label.hide()
			continue

		label.show()

		# --------------------------------------------------------
		# World → Screen
		# --------------------------------------------------------

		var screen_position: Vector2 = (
			camera.unproject_position(
				anchor.global_position
			)
		)

		var offset: Vector2 = (
			_shake_offsets.get(
				workstation,
				Vector2.ZERO
			)
		)

		label.position = (
			screen_position
			- label.size / 2.0
			+ offset
		)


# ----------------------------------------------------------------
# ERROR FEEDBACK
# ----------------------------------------------------------------

func _play_error_feedback(
	workstation: String
) -> void:

	var label: RichTextLabel = _labels.get(
		workstation
	)

	if label == null:
		return

	# ------------------------------------------------------------
	# Kill old tweens
	# ------------------------------------------------------------

	if _shake_tweens.has(workstation):
		var old_shake: Tween = _shake_tweens[workstation]

		if old_shake != null:
			old_shake.kill()

	if _flash_tweens.has(workstation):
		var old_flash: Tween = _flash_tweens[workstation]

		if old_flash != null:
			old_flash.kill()

	# ------------------------------------------------------------
	# Reset
	# ------------------------------------------------------------

	label.modulate = Color.WHITE

	_shake_offsets[workstation] = Vector2.ZERO

	# ------------------------------------------------------------
	# Flash red
	# ------------------------------------------------------------

	var flash_tween := create_tween()

	flash_tween.tween_property(
		label,
		"modulate",
		error_flash_color,
		error_flash_in_duration
	)

	flash_tween.tween_property(
		label,
		"modulate",
		Color.WHITE,
		error_flash_out_duration
	)

	_flash_tweens[workstation] = flash_tween

	# ------------------------------------------------------------
	# Shake
	# ------------------------------------------------------------

	var shake := error_shake_distance

	var shake_tween := create_tween()

	shake_tween.tween_method(
		_set_shake_x.bind(workstation),
		0.0,
		shake,
		0.04
	)

	shake_tween.tween_method(
		_set_shake_x.bind(workstation),
		shake,
		-shake,
		0.04
	)

	shake_tween.tween_method(
		_set_shake_x.bind(workstation),
		-shake,
		shake * 0.7,
		0.04
	)

	shake_tween.tween_method(
		_set_shake_x.bind(workstation),
		shake * 0.7,
		-shake * 0.7,
		0.04
	)

	shake_tween.tween_method(
		_set_shake_x.bind(workstation),
		-shake * 0.7,
		0.0,
		0.04
	)

	_shake_tweens[workstation] = shake_tween


# ----------------------------------------------------------------
# SHAKE HELPER
# ----------------------------------------------------------------

func _set_shake_x(
	x: float,
	workstation: String
) -> void:

	_shake_offsets[workstation] = Vector2(
		x,
		0.0
	)
