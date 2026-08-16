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

	prep_location_picker.register_location(
		"RICE_STORAGE", "BASKOM NASI BEKAS", $RiceStorage/PromptAnchor as Node3D
	)
	prep_location_picker.register_location(
		"REFRIGERATOR", "KULKAS", $Refrigerator/PromptAnchor as Node3D
	)
	prep_location_picker.register_location(
		"SEASONING", "TEMPAT BUMBU", $Seasoning/PromptAnchor as Node3D
	)


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
