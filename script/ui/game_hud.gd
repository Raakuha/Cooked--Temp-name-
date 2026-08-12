class_name GameHUD
extends CanvasLayer

@onready var profit_label : Label = $MarginContainer/ProfitLabel


func update_profit(value: int) -> void:
	profit_label.text = "Profit : Rp " + str(value)	
