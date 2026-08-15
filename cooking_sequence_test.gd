extends Node

@onready var cooking_sequence_manager: CookingSequenceManager = $CookingSequenceManager


func _ready() -> void:
	cooking_sequence_manager.start_recipe("nasgor_goreng")


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_accept"):
		return

	# R-P3-10: gak ada lagi 1 pointer linear buat di-next terus. Kalau
	# lagi gak ada prep item yang jalan, mulai salah satu yang eligible
	# dulu (yang pertama di list) -- baru tekan ui_accept lagi buat
	# lanjutin step-nya.
	var eligible: Array = cooking_sequence_manager.get_eligible_checklist_ids()

	if eligible.size() > 0:
		cooking_sequence_manager.start_prep_item(eligible[0])
	else:
		cooking_sequence_manager.next_step()


func _on_cooking_sequence_manager_recipe_started(recipe_id: String) -> void:
	print("RECIPE DIMULAI: ", recipe_id)


func _on_cooking_sequence_manager_step_started(step: Dictionary) -> void:
	print("STEP DATA: ", step)
	print("PROMPT: ", step["prompt"])
	print("--------------------")


func _on_cooking_sequence_manager_recipe_completed(result: CookingResult) -> void:
	print("RECIPE SELESAI: ", result.recipe_id)
	print("[CookingResult] ", result.to_dict())
