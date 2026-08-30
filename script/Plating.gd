extends Workstation
class_name Plating

signal food_plated(recipe_name: String)
signal food_taken(recipe_name: String)

var current_recipe: String = ""
var is_occupied: bool = false
@onready var menu_complete_sound: AudioStreamPlayer = $MenuCompleteSound

func plate_recipe(recipe_name: String) -> bool:
	if is_occupied:
		push_warning(
			"[Plating] Tempat plating sedang terisi: "
			+ current_recipe
		)
		return false

	current_recipe = recipe_name
	is_occupied = true

	print("[Plating] Makanan dihidangkan: ", current_recipe)
	if menu_complete_sound != null:
		menu_complete_sound.play()
	food_plated.emit(current_recipe)

	return true


func take_recipe() -> String:
	if not is_occupied:
		return ""

	var recipe_name := current_recipe

	current_recipe = ""
	is_occupied = false

	print("[Plating] Makanan diambil customer: ", recipe_name)

	food_taken.emit(recipe_name)

	return recipe_name


func has_recipe() -> bool:
	return is_occupied


func get_recipe() -> String:
	return current_recipe
