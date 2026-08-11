class_name SanityManager
extends Node

signal sanity_changed(current_sanity: int)

const MAX_SANITY: int = 100
const MIN_SANITY: int = 0

var current_sanity: int = MAX_SANITY


func reset_sanity() -> void:
	current_sanity = MAX_SANITY

	print("Sanity di-reset: ", current_sanity)

	sanity_changed.emit(current_sanity)


func increase_sanity(amount: int) -> void:
	current_sanity += amount
	current_sanity = clamp(current_sanity, MIN_SANITY, MAX_SANITY)

	print("Sanity bertambah: +", amount)
	print("Total sanity: ", current_sanity)

	sanity_changed.emit(current_sanity)


func decrease_sanity(amount: int) -> void:
	current_sanity -= amount
	current_sanity = clamp(current_sanity, MIN_SANITY, MAX_SANITY)

	print("Sanity berkurang: -", amount)
	print("Total sanity: ", current_sanity)

	sanity_changed.emit(current_sanity)


func get_sanity() -> int:
	return current_sanity
