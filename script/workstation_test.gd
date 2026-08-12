extends Node

@onready var csm: CookingSequenceManager = $CookingSequenceManager
@onready var executor: RecipeStepExecutor = $RecipeStepExecutor


func _ready() -> void:
	csm.step_started.connect(executor.execute_step)
	executor.step_completed.connect(csm.next_step)

	csm.recipe_started.connect(_on_recipe_started)
	csm.recipe_completed.connect(_on_recipe_completed)

	csm.start_recipe("nasgor_goreng")


func _on_recipe_started(recipe_id: String) -> void:
	print("RECIPE DIMULAI: ", recipe_id)


func _on_recipe_completed(result: CookingResult) -> void:
	print("RECIPE SELESAI: ", result.recipe_id)
	print("[CookingResult] ", result.to_dict())
