extends Node3D

@onready var customer : Customer = $Customer


func _ready():

	customer.customer_name = "Pak Budi"

	customer.walk_to_cashier()

	customer.walk_out()
