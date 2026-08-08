class_name CustomerManager
extends Node


signal customer_arrived


@export var customer_scene : PackedScene


var current_customer : Customer = null


func _on_customer_arrived():

	print("Customer sudah sampai di kasir.")

	customer_arrived.emit()


func spawn_customer():

	if current_customer != null:
		return


	current_customer = customer_scene.instantiate()

	add_child(current_customer)


	current_customer.customer_name = "Pak Budi"

	current_customer.arrived.connect(_on_customer_arrived)

	current_customer.walk_to_cashier()
