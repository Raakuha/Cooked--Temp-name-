extends Node
class_name CookingSequenceManager

signal recipe_started(recipe_id: String)
signal step_started(step: Dictionary)

# R-P3-06: cooking layer emit RESULT, bukan cuma recipe_id.
# Profit/Sanity yang baca result.mental_delta() di luar sini.
signal recipe_completed(result: CookingResult)

var recipe_id: String = ""
var steps: Array = []
var current_step_idx: int = 0
var active: bool = false

var current_result: CookingResult = null

var _typing_manager: TypingManager = null


func _ready() -> void:
	_typing_manager = get_node_or_null("../TypingManager")

	if _typing_manager != null:
		if not _typing_manager.typing_result.is_connected(_on_typing_result):
			_typing_manager.typing_result.connect(_on_typing_result)

	# R-P3-09: dengerin semua Workstation (grup "workstations") biar hasil
	# timing kompor (PERFECT/GOOD/MISS) ikut masuk ke CookingResult, tanpa
	# perlu ubah workstation.gd atau recipe_step_executor.gd sama sekali.
	for workstation in get_tree().get_nodes_in_group("workstations"):
		if workstation.has_signal("timing_result"):
			if not workstation.timing_result.is_connected(_on_stove_timing_result):
				workstation.timing_result.connect(_on_stove_timing_result)


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
		recipe_completed.emit(current_result)


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

	current_result = CookingResult.new()
	current_result.reset(recipe_id)

	print("RECIPE DIMULAI: ", recipe_id)

	var recipe_step_executor := get_node_or_null("../RecipeStepExecutor")

	if recipe_step_executor != null:
		recipe_step_executor.current_recipe_name = recipe_id

	recipe_started.emit(recipe_id)

	if steps.size() > 0:
		var first_step = get_current_step()
		step_started.emit(first_step)


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


# Hook R-P3-11 — menu_deadline_timer.gd sudah manggil ini, gak perlu diubah.
func mark_deadline_expired() -> void:
	if current_result != null:
		current_result.mark_deadline_expired()
