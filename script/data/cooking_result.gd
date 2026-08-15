class_name CookingResult
extends RefCounted

## R-P3-06 --- Cooking Result / Deadline Contract.
##
## Cooking runtime hanya melaporkan fakta dari satu order.
## Profit dan Sanity/Mental diproses downstream.
##
## ATURAN:
## - Typing mistake tidak mengubah hasil makanan.
## - Stove timing MISS dapat mengurangi profit sedikit.
## - Deadline habis membuat order FAILED.
## - Deadline failure tidak mengubah hasil makanan secara visual/gameplay.
## - Tidak ada mental/profit calculation di class ini.

var recipe_id: String = ""
var mistake_count: int = 0
var timing_summary: Array = []
var deadline_expired: bool = false


func reset(new_recipe_id: String) -> void:
	recipe_id = new_recipe_id
	mistake_count = 0
	timing_summary.clear()
	deadline_expired = false


func add_mistake(count: int = 1) -> void:
	if count <= 0:
		return

	mistake_count += count


func record_timing_result(timing_result: String) -> void:
	timing_summary.append(timing_result)


func mark_deadline_expired() -> void:
	deadline_expired = true


func get_timing_miss_count() -> int:
	var count := 0

	for result in timing_summary:
		if result == "MISS":
			count += 1

	return count


func is_success() -> bool:
	return not deadline_expired


func to_dict() -> Dictionary:
	return {
		"recipe_id": recipe_id,
		"success": is_success(),
		"mistake_count": mistake_count,
		"timing_summary": timing_summary.duplicate(),
		"timing_misses": get_timing_miss_count(),
		"deadline_expired": deadline_expired
	}
