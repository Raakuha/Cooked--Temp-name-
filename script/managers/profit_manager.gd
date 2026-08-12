class_name ProfitManager
extends Node

signal profit_changed(current_profit: int)

const SUCCESS_REWARD: int = 2000
const FAILURE_PENALTY: int = 2000

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


func customer_success() -> void:
	add_profit(SUCCESS_REWARD)


func customer_failed() -> void:
	subtract_profit(FAILURE_PENALTY)


func get_profit() -> int:
	return current_profit
