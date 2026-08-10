extends Node
class_name CookingSequenceManager

signal recipe_started(recipe_id: String)
signal step_started(step : Dictionary)
signal recipe_completed(recipe_id : String)

var recipe_id : String = ""
var steps : Array = []
var current_step_idx : int = 0
var active : bool = false


func get_current_step() -> Dictionary:
	if current_step_idx < steps.size():
		return steps[current_step_idx]
	
	return {}

func next_step() -> void:
	if not active:
		return

	current_step_idx += 1

	if current_step_idx < steps.size():
		var step = get_current_step()
		step_started.emit(step)
	else:
		active = false
		recipe_completed.emit(recipe_id)

func start_recipe(new_recipe_id: String) -> void:
	if active:
		return

	if not RecipeData.RECIPES.has(new_recipe_id):
		print("Recipe tidak ditemukan: ", new_recipe_id)
		return

	recipe_id = new_recipe_id
	steps = RecipeData.RECIPES[new_recipe_id]
	current_step_idx = 0
	active = true

	recipe_started.emit(recipe_id)

	if steps.size() > 0:
		var first_step = get_current_step()
		step_started.emit(first_step)
