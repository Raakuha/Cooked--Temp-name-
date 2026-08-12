extends Node

@onready var cooking_sequence_manager: CookingSequenceManager = $CookingSequenceManager



func _ready() -> void:
	cooking_sequence_manager.start_recipe("nasgor_goreng")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		cooking_sequence_manager.next_step()


func _on_cooking_sequence_manager_recipe_started(recipe_id: String) -> void:
	print("RECIPE DIMULAI: ", recipe_id)


func _on_cooking_sequence_manager_step_started(step: Dictionary) -> void:
	print("STEP INDEX: ", cooking_sequence_manager.current_step_idx)
	print("STEP DATA: ", step)
	print("PROMPT: ", step["prompt"])
	print("--------------------")


func _on_cooking_sequence_manager_recipe_completed(result: CookingResult) -> void:
	print("RECIPE SELESAI: ", result.recipe_id)
	print("[CookingResult] ", result.to_dict())
