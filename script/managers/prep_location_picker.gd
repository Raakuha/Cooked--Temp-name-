extends Node
class_name PrepLocationPicker

## R-P3-10 extension --- pemilihan LOKASI prep secara bebas.
##
## Begitu tidak ada prep item yang lagi aktif dikerjakan, komponen ini
## nampilin 1 prompt kecil di TIAP workstation yang masih punya minimal
## 1 checklist item eligible -- dikelompokkan per WORKSTATION, bukan per
## checklist_id. Kalau 1 workstation punya lebih dari 1 item eligible
## (mis. Kulkas: butter DAN daging_wagyu buat resep Steak), cuma 1
## prompt yang tampil di situ, mewakili SEMUA item yang eligible di
## sana. Begitu 1 item selesai, kalau workstation itu masih punya item
## lain yang eligible, dia bakal tetap muncul lagi di daftar prompt
## berikutnya -- player tinggal ngetik ulang (jalan/MOVE-nya bakal
## langsung kelar karena jaraknya deket/udah di situ).
##
## Player ngetik prompt lokasi mana aja, bebas urutan, buat mulai prep
## item PERTAMA yang masih eligible di situ lewat
## CookingSequenceManager.start_prep_item() yang sudah ada -- tidak ada
## yang berubah dari mekanisme itu.

signal location_prompt_started(candidates: Array)  # [{workstation,label,anchor}]
signal location_prompt_updated(states: Array)  # [{workstation,label,matched_len,had_mistake}]
signal location_prompt_cleared()

@export var cooking_sequence_manager: CookingSequenceManager

# Workstation command -> {"label": String, "anchor": Node3D}. Isi lewat
# Inspector atau lewat register_location() dari script lain kalau anchor-nya
# baru ready belakangan.
@export var location_labels: Dictionary = {}

var _candidates: Array = []
var _buffer: String = ""
var _listening: bool = false


func _ready() -> void:
	if cooking_sequence_manager == null:
		return

	cooking_sequence_manager.checklist_updated.connect(_on_checklist_changed)
	cooking_sequence_manager.prep_item_completed.connect(_on_prep_item_completed)
	cooking_sequence_manager.cooking_unlocked.connect(_on_cooking_unlocked)


func register_location(workstation: String, label: String, anchor: Node3D) -> void:
	location_labels[workstation] = {"label": label, "anchor": anchor}


func _on_checklist_changed(_checklist: Dictionary) -> void:
	_refresh()


func _on_prep_item_completed(_checklist_id: String) -> void:
	_refresh()


func _on_cooking_unlocked() -> void:
	_stop_listening()


func _refresh() -> void:
	if cooking_sequence_manager.active_prep_in_progress():
		return

	var eligible: Array = cooking_sequence_manager.get_eligible_checklist_ids()

	if eligible.is_empty():
		_stop_listening()
		return

	_build_candidates(eligible)

	if _candidates.is_empty():
		_stop_listening()
		return

	_buffer = ""
	_listening = true

	location_prompt_started.emit(_candidates.duplicate(true))
	_emit_state()


func _build_candidates(eligible: Array) -> void:
	_candidates.clear()

	var seen_workstations: Dictionary = {}

	for checklist_id in eligible:
		var workstation: String = cooking_sequence_manager.get_prep_workstation(checklist_id)

		if seen_workstations.has(workstation):
			continue

		seen_workstations[workstation] = true

		if not location_labels.has(workstation):
			push_error("PrepLocationPicker: belum ada location label buat workstation: " + workstation)
			continue

		var info: Dictionary = location_labels[workstation]

		_candidates.append({
			"workstation": workstation,
			"label": info["label"],
			"anchor": info["anchor"]
		})


func _stop_listening() -> void:
	_listening = false
	_candidates.clear()
	location_prompt_cleared.emit()


func _unhandled_key_input(event: InputEvent) -> void:
	if not _listening:
		return

	if not event is InputEventKey:
		return

	var key := event as InputEventKey

	if not key.pressed or key.echo:
		return

	if key.unicode == 0:
		return

	var input := String.chr(key.unicode).to_upper()

	if not "ABCDEFGHIJKLMNOPQRSTUVWXYZ".contains(input):
		return

	_check_input(input)
	get_viewport().set_input_as_handled()


func _check_input(input: String) -> void:
	var next_buffer: String = _buffer + input

	var still_matching: Array = []
	var full_match: Dictionary = {}

	for candidate in _candidates:
		# R-P3-10 extension: matching TANPA SPASI, sama pola kayak
		# ItemPickManager.strip_label() -- "BASKOM NASI BEKAS" diketik
		# "BASKOMNASIBEKAS".
		var stripped: String = ItemPickManager.strip_label(candidate["label"])

		if stripped.length() >= next_buffer.length() \
			and stripped.substr(0, next_buffer.length()) == next_buffer:
			still_matching.append(candidate)

			if stripped == next_buffer:
				full_match = candidate

	if still_matching.is_empty():
		_emit_state(true)
		return

	_buffer = next_buffer
	_emit_state(false)

	if not full_match.is_empty():
		_pick_location(full_match)


func _pick_location(candidate: Dictionary) -> void:
	var workstation: String = candidate["workstation"]
	var checklist_id: String = cooking_sequence_manager.get_first_eligible_at(workstation)

	# R-P3-10 fix: JANGAN _stop_listening() di sini -- itu nge-clear semua
	# label. Prompt lokasi harus TETAP keliatan sepanjang sesi prepare,
	# cuma berhenti nerima input sampai item ini kelar. _refresh() yang
	# bakal motret ulang daftarnya begitu prep_item_completed atau
	# checklist_updated nembak lagi. Baru _on_cooking_unlocked() yang
	# beneran nge-clear semuanya, di akhir sesi prepare.
	_listening = false
	_buffer = ""

	if checklist_id != "":
		cooking_sequence_manager.start_prep_item(checklist_id)


func _emit_state(had_mistake: bool = false) -> void:
	var states: Array = []

	for candidate in _candidates:
		var label: String = candidate["label"]
		var stripped: String = ItemPickManager.strip_label(label)
		var prefix_len: int = min(_buffer.length(), stripped.length())
		var matched_len := 0

		if stripped.substr(0, prefix_len) == _buffer.substr(0, prefix_len):
			matched_len = _buffer.length()

		states.append({
			"workstation": candidate["workstation"],
			"label": label,
			"matched_len": matched_len,  # posisi di LABEL TANPA SPASI
			"had_mistake": had_mistake
		})

	location_prompt_updated.emit(states)
