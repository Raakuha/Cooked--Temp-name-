extends Node

@onready var customer_manager : CustomerManager = $CustomerManager

func _ready():

	customer_manager.spawn_customer()
