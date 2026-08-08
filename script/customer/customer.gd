class_name Customer
extends Node3D


signal arrived
signal exited


var customer_name : String = ""


func walk_to_cashier():

	print(customer_name + " berjalan ke kasir")

	arrived.emit()


func walk_out():

	print(customer_name + " keluar restoran")

	exited.emit()

	queue_free()
