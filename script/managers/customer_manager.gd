class_name CustomerManager
extends Node

# =========================================================
# EXPORT
# =========================================================

@export var customer_scene : PackedScene

# =========================================================
# VARIABLE
# =========================================================

var current_customer : Customer = null

# =========================================================
# PUBLIC FUNCTION
# =========================================================

func _on_customer_arrived():

	print("Customer sudah sampai di kasir.")

func spawn_customer():

	if current_customer != null:
		return

	current_customer = customer_scene.instantiate()

	add_child(current_customer)

	current_customer.customer_name = "Pak Budi"

	current_customer.arrived.connect(_on_customer_arrived)

	current_customer.walk_to_cashier()
