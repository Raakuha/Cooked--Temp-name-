class_name SanityManager
extends Node

signal sanity_changed(current_sanity: int)
signal horror_threshold_reached(threshold: int)

const MAX_SANITY: int = 1000
const MIN_SANITY: int = 0
const SANITY_PER_100_PROFIT: int = 1

# Sementara untuk testing.
# Nanti angka ini bisa kita sesuaikan dengan balancing game.
const HORROR_THRESHOLDS: Array[int] = [70, 50, 30]

var current_sanity: int = MAX_SANITY
var triggered_thresholds: Array[int] = []


func reset_sanity() -> void:
	current_sanity = MAX_SANITY
	triggered_thresholds.clear()

	print("Sanity di-reset: ", current_sanity)

	sanity_changed.emit(current_sanity)


func increase_sanity(amount: int) -> void:
	current_sanity += amount
	current_sanity = clamp(current_sanity, MIN_SANITY, MAX_SANITY)

	print("Sanity bertambah: +", amount)
	print("Total sanity: ", current_sanity)

	sanity_changed.emit(current_sanity)


func decrease_sanity(amount: int) -> void:
	if amount <= 0:
		return

	var previous_sanity := current_sanity

	current_sanity -= amount
	current_sanity = clamp(current_sanity, MIN_SANITY, MAX_SANITY)

	print("Sanity berkurang: -", amount)
	print("Total sanity: ", current_sanity)

	sanity_changed.emit(current_sanity)

	_check_horror_threshold(previous_sanity)


func apply_profit_delta(profit_delta: int) -> void:
	if profit_delta == 0:
		return

	var sanity_delta := int(floor(abs(profit_delta) / float(SANITY_PER_100_PROFIT * 100.0)))
	if sanity_delta <= 0:
		return

	if profit_delta > 0:
		increase_sanity(sanity_delta)
	else:
		decrease_sanity(sanity_delta)


func failed_order() -> void:
	# Backward-compatible helper. Prefer apply_profit_delta().
	decrease_sanity(1)


func _check_horror_threshold(previous_sanity: int) -> void:
	for threshold in HORROR_THRESHOLDS:

		if threshold in triggered_thresholds:
			continue

		if previous_sanity > threshold and current_sanity <= threshold:
			triggered_thresholds.append(threshold)

			print("========================")
			print("HORROR THRESHOLD REACHED")
			print("Threshold :", threshold)
			print("Sanity :", current_sanity)
			print("========================")

			horror_threshold_reached.emit(threshold)


func get_sanity() -> int:
	return current_sanity
