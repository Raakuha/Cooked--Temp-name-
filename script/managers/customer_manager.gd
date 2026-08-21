class_name CustomerManager
extends Node


signal customer_arrived
signal customer_returned_to_cashier
signal customer_exited
signal customer_dialogue_requested(dialogue: Array[Dictionary])

@export var customer_scene : PackedScene


var current_customer : Customer = null
var customers_served: int = 0


@onready var customer_spawn : Marker3D = $"../../SpawnPoints/CustomerSpawn"
@onready var cashier_point : Marker3D = $"../../SpawnPoints/CashierPoint"
@onready var customer_exit : Marker3D = $"../../SpawnPoints/CustomerExit"

@onready var sit_point : Marker3D = $"../../DiningPoints/Table01/SitPoint"
@onready var customer_database: CustomerDatabase = $"../CustomerDatabase"

func add_customers_served(amount: int) -> void:

	customers_served += amount

	print(
		"Customers served bertambah : ",
		amount
	)

	print(
		"Customers served : ",
		customers_served
	)

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


func spawn_customer_by_profile(
	customer_profile: CustomerProfile,
	use_day6_variant: bool = false
) -> void:

	if current_customer != null:
		print("Masih ada customer.")
		return

	current_customer = customer_scene.instantiate()

	add_child(current_customer)

	current_customer.setup_from_profile(
		customer_profile
	)
	
	current_customer.use_day6_variant = use_day6_variant

	current_customer.global_position = customer_spawn.global_position

	current_customer.set_state(Customer.State.SPAWNING)

	print("========================")
	print("SPAWN CUSTOMER")
	print("ID :", customer_profile.character_id)
	print("Nama :", customer_profile.character_name)
	print("Recipe :", customer_profile.recipe_id)
	print("========================")

	current_customer.arrived.connect(_on_customer_arrived)
	current_customer.returned_to_cashier.connect(
		_on_customer_returned_to_cashier
	)

	current_customer.walk_to_cashier(
		cashier_point.global_position
	)





func get_customer_profile(customer_id: String) -> CustomerProfile:

	return customer_database.get_profile(customer_id)



func spawn_customer_by_id(customer_id: String) -> void:

	var profile := get_customer_profile(customer_id)

	if profile == null:
		return

	spawn_customer_by_profile(profile)


func request_opening_dialogue() -> void:

	if current_customer == null:
		return

	var dialogue := current_customer.get_opening_dialogue()

	print("Opening dialogue customer : ", current_customer.customer_name)

	customer_dialogue_requested.emit(dialogue)


func request_closing_dialogue() -> void:

	if current_customer == null:
		return

	var dialogue := current_customer.get_closing_dialogue()

	print("Closing dialogue customer : ", current_customer.customer_name)

	customer_dialogue_requested.emit(dialogue)


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
	customers_served += 1
	print("Customers served :", customers_served)
	current_customer = null
	customer_exited.emit()

func reset_customer_count() -> void:

	customers_served = 0

	print("Customer count di-reset.")

func get_customers_served() -> int:
	return customers_served


func spawn_mika_day6() -> void:

	var profile := customer_database.get_profile("mika")

	if profile == null:
		return

	spawn_customer_by_profile(
		profile,
		true
	)
