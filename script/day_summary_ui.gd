class_name DaySummaryUI
extends CanvasLayer


@onready var title: Label = (
	$Control/Content/Title
)

@onready var customer_value: Label = (
	$Control/Content/CustomerCard/
	MarginContainer/
	ContentRow/
	CustomerValue/
	Value
)

@onready var customer_unit: Label = (
	$Control/Content/CustomerCard/
	MarginContainer/
	ContentRow/
	CustomerValue/
	Unit
)

@onready var order_value: Label = (
	$Control/Content/OrdersCard/
	MarginContainer/
	ContentRow/
	OrderValue/
	Value
)

@onready var order_unit: Label = (
	$Control/Content/OrdersCard/
	MarginContainer/
	ContentRow/
	OrderValue/
	Unit
)

@onready var profit_currency: Label = (
	$Control/Content/ProfitCard/
	MarginContainer/
	ContentRow/
	ProfitValue/
	Currency
)

@onready var profit_amount: Label = (
	$Control/Content/ProfitCard/
	MarginContainer/
	ContentRow/
	ProfitValue/
	Amount
)


func _ready() -> void:

	hide()

	print("========================")
	print("DAY SUMMARY UI READY")
	print("========================")


func show_summary(
	day: int,
	customers_served: int,
	orders_completed: int,
	profit: int
) -> void:

	title.text = "Day %d Complete" % day

	customer_value.text = str(customers_served)
	customer_unit.text = "People"

	order_value.text = str(orders_completed)
	order_unit.text = "Orders"

	profit_currency.text = "Rp"
	profit_amount.text = format_currency(profit)

	show()

	print("========================")
	print("DAY SUMMARY")
	print("Day :", day)
	print("Customers :", customers_served)
	print("Orders :", orders_completed)
	print("Profit : Rp", format_currency(profit))
	print("========================")


func format_currency(value: int) -> String:

	var number: int = abs(value)

	if number < 1000:
		if value < 0:
			return "-" + str(number)

		return str(number)

	var text: String = str(number)
	var result: String = ""

	while text.length() > 3:

		result = "." + text.substr(
			text.length() - 3,
			3
		) + result

		text = text.substr(
			0,
			text.length() - 3
		)

	result = text + result

	if value < 0:
		result = "-" + result

	return result



func hide_summary() -> void:
	hide()
