class_name CookingResult
extends RefCounted

## R-P3-06 --- Cooking Result / Deadline Contract
##
## Cooking layer CUMA melaporkan apa yang terjadi selama masak satu resep.
## Profit/Sanity system di luar (downstream) yang mutuskan konsekuensi
## finansial & mental berdasarkan data ini.
##
## PENTING: dish akhir TIDAK PERNAH berubah gara-gara mistake, timing MISS,
## atau menu-timer expiry. Semua itu cuma nambah mental_delta.

const MENTAL_PENALTY_PER_MISTAKE := 1
const MENTAL_PENALTY_PER_TIMING_MISS := 2
const MENTAL_PENALTY_PER_DEADLINE_EXPIRED := 5

var recipe_id: String = ""
var mistake_count: int = 0

# Diisi belakangan oleh R-P3-09 (stove timing skill-window).
# Isi: array of String "PERFECT" / "GOOD" / "MISS", satu entry per timing
# check dalam resep ini.
var timing_summary: Array = []

# Diisi belakangan oleh R-P3-11 (menu deadline timer).
var deadline_expired: bool = false


func reset(new_recipe_id: String) -> void:
	recipe_id = new_recipe_id
	mistake_count = 0
	timing_summary.clear()
	deadline_expired = false


func add_mistake(count: int = 1) -> void:
	mistake_count += count


func record_timing_result(timing_result: String) -> void:
	timing_summary.append(timing_result)


func mark_deadline_expired() -> void:
	deadline_expired = true


func mental_delta() -> int:
	var delta := mistake_count * MENTAL_PENALTY_PER_MISTAKE

	for result in timing_summary:
		if result == "MISS":
			delta += MENTAL_PENALTY_PER_TIMING_MISS

	if deadline_expired:
		delta += MENTAL_PENALTY_PER_DEADLINE_EXPIRED

	return delta


func to_dict() -> Dictionary:
	return {
		"recipe_id": recipe_id,
		"mistake_count": mistake_count,
		"timing_summary": timing_summary.duplicate(),
		"deadline_expired": deadline_expired,
		"mental_delta": mental_delta()
	}
