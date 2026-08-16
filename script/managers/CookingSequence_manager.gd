extends Node
class_name CookingSequenceManager

signal recipe_started(recipe_id: String)
signal step_started(step: Dictionary)

# R-P3-10: checklist state, dipancarkan tiap kali berubah (termasuk saat
# start_recipe, biar UI/orkestrasi selalu punya state awal yang benar).
signal checklist_updated(checklist: Dictionary)

# R-P3-10: fired sekali per prep item begitu selesai.
signal prep_item_completed(checklist_id: String)

# R-P3-10: fired sekali begitu semua prep item selesai dan fase cooking
# (yang tetap terurut) mulai jalan.
signal cooking_unlocked

# R-P3-06: cooking layer emit RESULT, bukan cuma recipe_id.
# Profit/Sanity yang baca datanya di luar sini.
signal recipe_completed(result: CookingResult)

var recipe_id: String = ""
var active: bool = false

var current_result: CookingResult = null

# --- R-P3-10: state PREP (checklist, bebas urutan) ---
var _prep_items: Array = []          # dari RecipeData.RECIPES[id]["prep"]
var _checklist: Dictionary = {}      # checklist_id -> bool (selesai/belum)
var _active_prep_index: int = -1     # index ke _prep_items, -1 = tidak ada yang jalan
var _active_prep_step_idx: int = 0

# --- state COOKING (tetap terurut, sama seperti sebelumnya) ---
var _cooking_steps: Array = []       # dari RecipeData.RECIPES[id]["cooking"]
var _cooking_step_idx: int = 0
var _in_cooking_phase: bool = false

var _typing_manager: TypingManager = null

# R-P3-10 fix: SEMUA item_id yang beneran kepetik BENAR di kunjungan
# prep yang lagi jalan (bisa lebih dari 1, kalau workstation-nya punya
# beberapa checklist item eligible sekaligus, mis. daging_cincang DAN
# telur sama-sama di REFRIGERATOR). Direset tiap kali 1 prep item
# selesai diproses.
var _picked_item_ids_this_action: Array = []


func _ready() -> void:
	_typing_manager = get_node_or_null("../TypingManager")

	if _typing_manager != null:
		if not _typing_manager.typing_result.is_connected(_on_typing_result):
			_typing_manager.typing_result.connect(_on_typing_result)

	# R-P3-09: dengerin semua Workstation (grup "workstations") biar hasil
	# timing kompor (PERFECT/GOOD/MISS) ikut masuk ke CookingResult.
	for workstation in get_tree().get_nodes_in_group("workstations"):
		if workstation.has_signal("timing_result"):
			if not workstation.timing_result.is_connected(_on_stove_timing_result):
				workstation.timing_result.connect(_on_stove_timing_result)

		# R-P3-10 extension: salah ambil barang di workstation ber-inventory
		# ikut nyumbang mistake ke CookingResult, sama kayak salah ketik.
		if workstation.has_signal("wrong_item_picked"):
			if not workstation.wrong_item_picked.is_connected(_on_wrong_item_picked):
				workstation.wrong_item_picked.connect(_on_wrong_item_picked)

		# R-P3-10 fix: dengerin barang APA yang beneran kepetik BENAR,
		# biar _complete_active_prep_item() bisa nyocokin checklist_id yang
		# tepat -- bukan asumsi checklist_id yang lagi "aktif".
		if workstation.has_signal("item_picked"):
			if not workstation.item_picked.is_connected(_on_item_picked):
				workstation.item_picked.connect(_on_item_picked)


func start_recipe(new_recipe_id: String) -> void:
	if active:
		return

	if not RecipeData.RECIPES.has(new_recipe_id):
		print("Recipe tidak ditemukan: ", new_recipe_id)
		return

	var recipe_def: Dictionary = RecipeData.RECIPES[new_recipe_id]

	recipe_id = new_recipe_id
	_prep_items = recipe_def.get("prep", [])
	_cooking_steps = recipe_def.get("cooking", [])

	_checklist.clear()

	for item in _prep_items:
		_checklist[item["checklist_id"]] = false

	_active_prep_index = -1
	_active_prep_step_idx = 0
	_picked_item_ids_this_action.clear()
	_in_cooking_phase = false
	_cooking_step_idx = 0
	active = true

	current_result = CookingResult.new()
	current_result.reset(recipe_id)

	print("RECIPE DIMULAI: ", recipe_id)

	var recipe_step_executor := get_node_or_null("../RecipeStepExecutor")

	if recipe_step_executor != null:
		recipe_step_executor.current_recipe_name = recipe_id

	recipe_started.emit(recipe_id)
	checklist_updated.emit(_checklist.duplicate())

	# Jaga-jaga kalau suatu resep didefinisikan tanpa prep item sama sekali.
	if _prep_items.is_empty():
		_start_cooking_phase()


# ------------------------------------------------------------------
# R-P3-10 --- PREP (checklist, bebas urutan)
# ------------------------------------------------------------------

# Daftar checklist_id yang masih boleh dikerjakan (belum selesai).
# Dipanggil orkestrasi/UI buat tau prep item mana aja yang eligible.
func get_eligible_checklist_ids() -> Array:
	var eligible: Array = []

	for checklist_id in _checklist.keys():
		if not _checklist[checklist_id]:
			eligible.append(checklist_id)

	return eligible

func active_prep_in_progress() -> bool:
	return _active_prep_index != -1
	
func get_prep_workstation(checklist_id: String) -> String:
	for item in _prep_items:
		if item["checklist_id"] == checklist_id:
			var steps: Array = item["steps"]

			if steps.size() > 0:
				return steps[0]["workstation"]

	return ""

func get_first_eligible_at(workstation: String) -> String:
	for checklist_id in get_eligible_checklist_ids():
		if get_prep_workstation(checklist_id) == workstation:
			return checklist_id

	return ""


# R-P3-10 fix: semua item_id yang SAH diambil sekarang di 1 workstation --
# bisa lebih dari 1 kalau ada beberapa checklist item yang kebetulan
# nunjuk ke workstation yang sama (mis. daging & telur sama-sama di
# REFRIGERATOR). Dipakai buat ngasih tau Workstation "barang mana aja
# yang boleh diterima sekarang", bukan cuma 1 yang "seharusnya" menurut
# urutan data.
func _get_eligible_item_ids_at(workstation: String) -> Array:
	var ids: Array = []

	for checklist_id in get_eligible_checklist_ids():
		if get_prep_workstation(checklist_id) != workstation:
			continue

		for item in _prep_items:
			if item["checklist_id"] != checklist_id:
				continue

			for s in item["steps"]:
				if s["type"] == RecipeData.StepType.ACTION:
					var inter: Dictionary = s.get("interaction", {})

					if inter.has("item_id"):
						ids.append(inter["item_id"])

	return ids


# Mulai kerjain 1 prep item tertentu, urutan bebas dipanggil dari luar
# kapan aja (selama belum masuk fase cooking dan item itu belum selesai).
func start_prep_item(checklist_id: String) -> bool:
	if not active or _in_cooking_phase:
		return false

	if _active_prep_index != -1:
		print("Masih ada prep item lain yang sedang dikerjakan.")
		return false

	if not _checklist.has(checklist_id):
		push_error("Checklist ID tidak dikenal: " + checklist_id)
		return false

	if _checklist[checklist_id]:
		print("Prep item sudah selesai, tidak bisa diulang: ", checklist_id)
		return false

	for i in _prep_items.size():
		if _prep_items[i]["checklist_id"] == checklist_id:
			_active_prep_index = i
			_active_prep_step_idx = 0

			var steps: Array = _prep_items[i]["steps"]

			if steps.size() > 0:
				step_started.emit(steps[0])

			return true

	return false


func _complete_active_prep_item() -> void:
	if _picked_item_ids_this_action.is_empty():
		# R-P3-10 fix: player keluar workstation TANPA ambil barang apapun
		# -- ini bukan "selesai", checklist TETAP kosong/belum. Cuma reset
		# state biar PrepLocationPicker bisa nawarin lokasi lagi (termasuk
		# workstation yang sama, kalau mau dicoba lagi nanti).
		_active_prep_index = -1
		_active_prep_step_idx = 0

		print("[CookingSequenceManager] Prep dibatalkan, keluar tangan kosong.")

		# Reuse sinyal ini cuma buat trigger PrepLocationPicker._refresh()
		# lagi -- isinya emang gak berubah (checklist tetap sama).
		checklist_updated.emit(_checklist.duplicate())
		return

	var checklist_ids: Array = _resolve_completed_checklist_ids()

	for checklist_id in checklist_ids:
		_checklist[checklist_id] = true

	_active_prep_index = -1
	_active_prep_step_idx = 0
	_picked_item_ids_this_action.clear()

	for checklist_id in checklist_ids:
		print("[CookingSequenceManager] Prep item selesai: ", checklist_id)
		prep_item_completed.emit(checklist_id)

	checklist_updated.emit(_checklist.duplicate())

	if _all_prep_complete():
		_start_cooking_phase()


# R-P3-10 fix: cari SEMUA checklist_id yang cocok sama barang-barang yang
# beneran kepetik BENAR di kunjungan ini (_picked_item_ids_this_action) --
# sebelumnya cuma resolve 1 checklist_id (dari barang TERAKHIR yang
# kepetik), jadi kalau ambil 2+ barang dalam 1 kunjungan, yang lain gak
# pernah ke-mark selesai. Fallback ke checklist yang lagi aktif kalau gak
# ada info item_id sama sekali (mis. workstation lama tanpa ItemPickManager).
func _resolve_completed_checklist_ids() -> Array:
	var resolved: Array = []

	for picked_item_id in _picked_item_ids_this_action:
		for item in _prep_items:
			var checklist_id: String = item["checklist_id"]

			if _checklist.get(checklist_id, true):
				continue

			if resolved.has(checklist_id):
				continue

			for s in item["steps"]:
				if s["type"] == RecipeData.StepType.ACTION:
					var inter: Dictionary = s.get("interaction", {})

					if inter.get("item_id", "") == picked_item_id:
						resolved.append(checklist_id)

	if resolved.is_empty():
		resolved.append(_prep_items[_active_prep_index]["checklist_id"])

	return resolved


func _all_prep_complete() -> bool:
	for completed in _checklist.values():
		if not completed:
			return false

	return true


# ------------------------------------------------------------------
# COOKING (tetap terurut, sama seperti sebelumnya)
# ------------------------------------------------------------------

func _start_cooking_phase() -> void:
	_in_cooking_phase = true
	_cooking_step_idx = 0

	print("[CookingSequenceManager] Semua prep selesai, cooking dimulai.")

	cooking_unlocked.emit()

	if _cooking_steps.size() > 0:
		step_started.emit(_cooking_steps[0])
	else:
		# Resep tanpa fase cooking (minuman) -- langsung selesai.
		active = false
		recipe_completed.emit(current_result)


# Dipanggil RecipeStepExecutor lewat step_completed, persis kayak dulu --
# fungsi ini yang nentuin "lanjut ke mana" tergantung fase saat ini.
func next_step() -> void:
	if not active:
		return

	if not _in_cooking_phase:
		if _active_prep_index == -1:
			return

		_active_prep_step_idx += 1

		var steps: Array = _prep_items[_active_prep_index]["steps"]

		if _active_prep_step_idx < steps.size():
			_emit_prep_step(steps[_active_prep_step_idx])
		else:
			_complete_active_prep_item()
	else:
		_cooking_step_idx += 1

		if _cooking_step_idx < _cooking_steps.size():
			step_started.emit(_cooking_steps[_cooking_step_idx])
		else:
			active = false
			recipe_completed.emit(current_result)


# R-P3-10 fix: kalau step ini TAKE dan punya interaction.item_id, expand
# dulu jadi "item_ids" (jamak) berisi SEMUA barang yang sah diambil
# sekarang di workstation itu -- bukan cuma 1 item_id spesifik dari data.
# Ini yang bikin Workstation.run_take_action() bisa nerima barang APA AJA
# yang masih eligible, bukan cuma yang "seharusnya" menurut urutan resep.
func _emit_prep_step(step: Dictionary) -> void:
	if step.get("type") == RecipeData.StepType.ACTION 		and step.get("action") == RecipeData.ActionType.TAKE:
		var interaction: Dictionary = step.get("interaction", {})

		if interaction.has("item_id"):
			var expanded: Dictionary = step.duplicate(true)
			expanded["interaction"] = interaction.duplicate(true)
			expanded["interaction"]["item_ids"] = \
				_get_eligible_item_ids_at(step["workstation"])

			step_started.emit(expanded)
			return

	step_started.emit(step)


func _on_item_picked(_workstation: Workstation, item_id: String) -> void:
	_picked_item_ids_this_action.append(item_id)


# ------------------------------------------------------------------
# R-P3-06: kumpulin fakta mentah selama resep berjalan.
# ------------------------------------------------------------------

func _on_typing_result(_target_word: String, mistake_count: int) -> void:
	if not active or current_result == null:
		return

	if mistake_count > 0:
		current_result.add_mistake(mistake_count)


# R-P3-09: satu ronde stove timing bisa punya beberapa hasil (mis. 3x MIX),
# semuanya dicatat satu-satu ke result yang sama.
func _on_stove_timing_result(
	_workstation: Workstation, _action_name: String, results: Array
) -> void:
	if not active or current_result == null:
		return

	for result in results:
		current_result.record_timing_result(String(result))


# Tetap disediakan buat pemanggil lain yang cuma punya 1 hasil timing.
func record_timing_result(timing_result: String) -> void:
	if current_result != null:
		current_result.record_timing_result(timing_result)



func _on_wrong_item_picked(
	_workstation: Workstation, _picked_item_id: String, _required_item_id: String
) -> void:
	if not active or current_result == null:
		return

	current_result.add_mistake(1)


# Hook R-P3-11 -- menu_deadline_timer.gd sudah manggil ini, gak perlu diubah.
func mark_deadline_expired() -> void:
	if current_result != null:
		current_result.mark_deadline_expired()
