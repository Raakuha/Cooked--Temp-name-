extends Node

@onready var csm: CookingSequenceManager = $CookingSequenceManager
@onready var executor: RecipeStepExecutor = $RecipeStepExecutor
@onready var prep_location_picker: PrepLocationPicker = $PrepLocationPicker


func _ready() -> void:
	csm.step_started.connect(executor.execute_step)
	executor.step_completed.connect(csm.next_step)

	csm.recipe_started.connect(_on_recipe_started)
	csm.recipe_completed.connect(_on_recipe_completed)
	csm.checklist_updated.connect(_on_checklist_updated)
	csm.prep_item_completed.connect(_on_prep_item_completed)
	csm.cooking_unlocked.connect(_on_cooking_unlocked)

	# R-P3-10 extension: register_location() HARUS sebelum start_recipe(),
	# soalnya start_recipe() langsung emit checklist_updated -> PrepLocationPicker
	# langsung _refresh() begitu recipe mulai. Kalau kebalik, giliran pertama
	# location_labels masih kosong buat RICE_STORAGE -- gak nongol.
	#
	# CATATAN: nasgor_goreng butuh 4 lokasi (RICE_STORAGE, REFRIGERATOR,
	# PRODUCE, SEASONING) tapi baru RICE_STORAGE yang diregister di sini.
	# 3 lainnya bakal push_error "belum ada location label" begitu eligible
	# -- itu bukan crash, cuma checklist_id di 3 lokasi itu gak akan pernah
	# muncul prompt-nya sampai kamu register_location() buat masing-masing.
	prep_location_picker.register_location(
		"RICE_STORAGE", "BASKOM NASI BEKAS", $RiceStorage/PromptAnchor as Node3D
	)
	prep_location_picker.register_location(
		"REFRIGERATOR", "KULKAS", $Refrigerator/PromptAnchor as Node3D
	)
	prep_location_picker.register_location(
		"SEASONING", "TEMPAT BUMBU", $Seasoning/PromptAnchor as Node3D
	)

	# R-P3-10 extension: gak ada lagi auto-sequencer manual di sini.
	# Prep item sekarang dimulai lewat PrepLocationPicker (player ngetik
	# nama lokasi yang lagi eligible, lihat prep_location_picker.gd).
	csm.start_recipe("nasgor_goreng")


func _on_prep_item_completed(checklist_id: String) -> void:
	print("[TEST] Prep item selesai: ", checklist_id)


func _on_checklist_updated(checklist: Dictionary) -> void:
	print("[TEST] Checklist sekarang: ", checklist)


func _on_cooking_unlocked() -> void:
	print("[TEST] === COOKING UNLOCKED, semua prep selesai ===")


func _on_recipe_started(recipe_id: String) -> void:
	print("RECIPE DIMULAI: ", recipe_id)


func _on_recipe_completed(result: CookingResult) -> void:
	print("RECIPE SELESAI: ", result.recipe_id)
	print("[CookingResult] ", result.to_dict())
