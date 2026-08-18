class_name DaySummaryUI
extends CanvasLayer

@onready var day_label: Label = $Control/DayLabel
@onready var customer_label: Label = $Control/CustomerLabel
@onready var profit_label: Label = $Control/ProfitLabel


func _ready() -> void:
	hide()

	print("========================")
	print("DAY SUMMARY UI READY")
	print("========================")


func show_summary(
	day: int,
	customers_served: int,
	profit: int
) -> void:

	show()

	day_label.text = "DAY %d COMPLETE" % day
	customer_label.text = "Customers Served : %d" % customers_served
	profit_label.text = "Profit : Rp %d" % profit

	print("========================")
	print("DAY SUMMARY")
	print("Day :", day)
	print("Customers :", customers_served)
	print("Profit :", profit)
	print("========================")


func hide_summary() -> void:
	hide()
