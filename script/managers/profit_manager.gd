class_name ProfitManager
extends Node

signal profit_changed(current_profit: int)

const SUCCESS_REWARD: int = 2000
const FAILURE_PENALTY: int = 2000
const TIMING_MISS_PENALTY: int = 200

var current_profit: int = 0


func reset_profit() -> void:
	current_profit = 0
	profit_changed.emit(current_profit)

	print("Profit di-reset: Rp", current_profit)


func add_profit(amount: int) -> void:
	current_profit += amount

	print("Profit bertambah: +Rp", amount)
	print("Total profit: Rp", current_profit)

	profit_changed.emit(current_profit)


func subtract_profit(amount: int) -> void:
	current_profit -= amount

	print("Profit berkurang: -Rp", amount)
	print("Total profit: Rp", current_profit)

	profit_changed.emit(current_profit)


func customer_success() -> int:
	add_profit(SUCCESS_REWARD)
	return SUCCESS_REWARD


func customer_success_with_timing_misses(timing_miss_count: int) -> int:
	var miss_count := maxi(timing_miss_count, 0)
	var reward := SUCCESS_REWARD - (miss_count * TIMING_MISS_PENALTY)
	reward = maxi(reward, 0)

	add_profit(reward)
	return reward


func customer_failed() -> int:
	subtract_profit(FAILURE_PENALTY)
	return -FAILURE_PENALTY


func apply_cooking_result(result: CookingResult) -> int:
	if result == null:
		push_warning("ProfitManager: cooking result null.")
		return 0

	if result.is_success():
		return customer_success_with_timing_misses(
			result.get_timing_miss_count()
		)

	return customer_failed()


func get_profit() -> int:
	return current_profit
