class_name CustomerManager
extends Node


signal customer_arrived
signal customer_returned_to_cashier
signal customer_exited


@export var customer_scene : PackedScene

var current_customer : Customer = null


@onready var customer_spawn : Marker3D = $"../../SpawnPoints/CustomerSpawn"
@onready var cashier_point : Marker3D = $"../../SpawnPoints/CashierPoint"
@onready var customer_exit : Marker3D = $"../../SpawnPoints/CustomerExit"

@onready var sit_point : Marker3D = $"../../DiningPoints/Table01/SitPoint"

func send_customer_to_table():
	if current_customer == null:
		return

	print("Customer pergi ke meja")

	current_customer.walk_to_table(
		sit_point.global_position,
		cashier_point.global_position
	)

func _on_customer_arrived():

	print("Customer sudah sampai di kasir.")

	if current_customer != null:
		current_customer.set_state(Customer.State.ORDERING)

	customer_arrived.emit()


func spawn_customer(customer_name : String = "Pak Budi"):

	print("========================")
	print("SPAWN CUSTOMER")
	print("Nama :", customer_name)
	print("Scene :", customer_scene)
	print("========================")

	if current_customer != null:

		print("Masih ada customer.")

		return

	current_customer = customer_scene.instantiate()

	add_child(current_customer)

	current_customer.customer_name = customer_name
	current_customer.global_position = customer_spawn.global_position

	current_customer.set_state(Customer.State.SPAWNING)

	print("Customer dibuat :", current_customer)
	print("Posisi spawn :", current_customer.global_position)
	print("Posisi kasir :", cashier_point.global_position)

	current_customer.arrived.connect(_on_customer_arrived)
	current_customer.returned_to_cashier.connect(_on_customer_returned_to_cashier)

	current_customer.walk_to_cashier(
		cashier_point.global_position
	)

func _on_customer_returned_to_cashier():

	print("Customer kembali ke kasir")

	customer_returned_to_cashier.emit()

func return_customer_to_cashier():

	if current_customer == null:
		return

	current_customer.return_to_cashier(
		cashier_point.global_position
	)

func exit_customer():

	if current_customer == null:

		print("Tidak ada customer untuk keluar.")

		return


	current_customer.exited.connect(_on_customer_exited)

	current_customer.walk_out(
		customer_exit.global_position
	)


func _on_customer_exited():

	print("Customer benar-benar sudah keluar")

	current_customer = null

	customer_exited.emit()
