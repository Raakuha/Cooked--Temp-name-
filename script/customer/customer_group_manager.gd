class_name CustomerGroupManager
extends Node

signal group_started
signal member_arrived(customer)
signal member_finished(customer)
signal group_closing_requested(customer)
signal group_finished


@export var customer_scene: PackedScene
@export var group_profiles: Array[CustomerGroup] = []

@onready var group_spawn_1: Marker3D = $"../../SpawnPoints/GroupSpawn1"
@onready var group_spawn_2: Marker3D = $"../../SpawnPoints/GroupSpawn2"
@onready var group_spawn_3: Marker3D = $"../../SpawnPoints/GroupSpawn3"

@onready var group_wait_1: Marker3D = $"../../SpawnPoints/GroupWait1"
@onready var group_wait_2: Marker3D = $"../../SpawnPoints/GroupWait2"
@onready var group_wait_3: Marker3D = $"../../SpawnPoints/GroupWait3"

@onready var group_exit_1: Marker3D = $"../../SpawnPoints/GroupExit1"
@onready var group_exit_2: Marker3D = $"../../SpawnPoints/GroupExit2"
@onready var group_exit_3: Marker3D = $"../../SpawnPoints/GroupExit3"

@onready var cashier_point: Marker3D = $"../../SpawnPoints/CashierPoint"

@onready var sit_point_1: Marker3D = $"../../DiningPoints/Table02/SitPoint1"
@onready var sit_point_2: Marker3D = $"../../DiningPoints/Table02/SitPoint2"
@onready var sit_point_3: Marker3D = $"../../DiningPoints/Table02/SitPoint3"

var group_map: Dictionary = {}

var current_group: CustomerGroup = null
var spawned_members: Array[Customer] = []
var current_member_index: int = 0

var current_customer: Customer = null

var dining_finished_members: Array[Customer] = []
var exited_members: Array[Customer] = []

var last_group_member_count: int = 0

func _ready() -> void:

	for group in group_profiles:

		if group == null:
			continue

		group_map[group.group_id] = group

	print("========================")
	print("CUSTOMER GROUP MANAGER READY")
	print("Groups :", group_map.size())
	print("========================")



func get_group(group_id: String) -> CustomerGroup:

	if not group_map.has(group_id):
		print("Group ID tidak ditemukan: ", group_id)
		return null

	return group_map[group_id]



func start_group(group_id: String) -> void:

	if current_group != null:
		print("Masih ada group aktif.")
		return

	var group := get_group(group_id)

	if group == null:
		return

	current_group = group
	spawned_members.clear()
	current_member_index = 0

	print("========================")
	print("START CUSTOMER GROUP")
	print("Group :", group.group_id)
	print("Members :", group.members.size())
	print("========================")

	var spawn_positions := [
		group_spawn_1.global_position,
		group_spawn_2.global_position,
		group_spawn_3.global_position
	]

	for i in range(group.members.size()):

		var profile := group.members[i]

		if profile == null:
			continue

		var customer: Customer = customer_scene.instantiate()

		add_child(customer)

		customer.customer_name = profile.character_name
		customer.global_position = spawn_positions[i]

		customer.setup_from_profile(profile)
		
		customer.dining_finished.connect(
			_on_member_dining_finished.bind(customer)
		)
		
		spawned_members.append(customer)

	group_started.emit()

	move_group_to_waiting_area()


func move_group_to_waiting_area() -> void:

	print("========================")
	print("GROUP MOVING TO WAITING AREA")
	print("========================")

	var wait_positions := [
		group_wait_1.global_position,
		group_wait_2.global_position,
		group_wait_3.global_position
	]

	for i in range(spawned_members.size()):

		spawned_members[i].walk_to_group_wait(
			wait_positions[i]
		)

	await get_tree().create_timer(1.7).timeout

	print("========================")
	print("GROUP ARRIVED TO WAITING AREA")
	print("========================")

	current_member_index = 0
	start_next_member()


func exit_group() -> void:

	print("========================")
	print("GROUP EXIT")
	print("========================")

	exited_members.clear()

	var exit_positions := [
		group_exit_1.global_position,
		group_exit_2.global_position,
		group_exit_3.global_position
	]

	for i in range(spawned_members.size()):

		var customer := spawned_members[i]

		customer.exited.connect(
			_on_group_member_exited.bind(customer),
			CONNECT_ONE_SHOT
		)

		customer.walk_out(
			exit_positions[i]
		)


func _on_group_member_exited(customer: Customer) -> void:

	if exited_members.has(customer):
		return

	exited_members.append(customer)

	print("========================")
	print(
		"GROUP MEMBER EXITED -> ",
		customer.customer_name
	)
	print(
		"Exited : ",
		exited_members.size(),
		"/",
		spawned_members.size()
	)
	print("========================")

	if exited_members.size() >= spawned_members.size():

		finish_group()



func start_next_member() -> void:

	if current_member_index >= spawned_members.size():

		print("========================")
		print("SEMUA MEMBER SUDAH SAMPAI DI MEJA")
		print("MENUNGGU SEMUA SELESAI MAKAN")
		print("========================")

		return

	current_customer = spawned_members[current_member_index]

	print("========================")
	print("GROUP MEMBER START")
	print(
		current_member_index + 1,
		"/",
		spawned_members.size()
	)
	print(
		"Customer : ",
		current_customer.customer_name
	)
	print("========================")

	current_customer.arrived.connect(
		_on_member_arrived,
		CONNECT_ONE_SHOT
	)

	current_customer.walk_to_cashier(
		cashier_point.global_position
	)


func finish_group() -> void:

	print("========================")
	print("CUSTOMER GROUP FINISHED")
	print("Group :", current_group.group_id)
	print("========================")

	last_group_member_count = spawned_members.size()

	group_finished.emit()

	current_customer = null
	spawned_members.clear()
	dining_finished_members.clear()
	exited_members.clear()

	current_member_index = 0
	current_group = null


func _on_member_arrived() -> void:

	print(
		"GROUP MEMBER ARRIVED : ",
		current_customer.customer_name
	)

	member_arrived.emit(current_customer)



func send_current_member_to_table() -> void:

	if current_customer == null:
		return

	var target: Vector3

	match current_member_index:

		0:
			target = sit_point_1.global_position

		1:
			target = sit_point_2.global_position

		2:
			target = sit_point_3.global_position

		_:
			return

	current_customer.table_arrived.connect(
		_on_current_member_table_arrived,
		CONNECT_ONE_SHOT
	)

	current_customer.walk_to_table(
		target,
		cashier_point.global_position,
		false
	)


func _on_current_member_table_arrived() -> void:

	if current_customer == null:
		return

	print("========================")
	print(
		"GROUP MEMBER ARRIVED AT TABLE -> ",
		current_customer.customer_name
	)
	print("========================")

	# Anggota ini sudah selesai tahap pemesanan
	# dan sudah berada di meja.
	current_member_index += 1

	# Mulai anggota berikutnya.
	start_next_member()


func _on_member_dining_finished(customer: Customer) -> void:

	if dining_finished_members.has(customer):
		return

	dining_finished_members.append(customer)

	print("========================")
	print(
		"GROUP MEMBER SELESAI MAKAN -> ",
		customer.customer_name
	)
	print(
		"Dining selesai : ",
		dining_finished_members.size(),
		"/",
		spawned_members.size()
	)
	print("========================")

	if dining_finished_members.size() >= spawned_members.size():

		begin_group_closing()


func begin_group_closing() -> void:

	print("========================")
	print("ALL GROUP MEMBERS FINISHED DINING")
	print("========================")

	var leader := spawned_members[0]

	current_customer = leader

	print(
		"GROUP LEADER RETURNING TO CASHIER -> ",
		leader.customer_name
	)

	leader.returned_to_cashier.connect(
		_on_group_leader_returned,
		CONNECT_ONE_SHOT
	)

	leader.return_to_cashier(
		cashier_point.global_position
	)


func _on_group_leader_returned() -> void:

	print("========================")
	print("GROUP LEADER RETURNED TO CASHIER")
	print("========================")

	var leader := spawned_members[0]

	group_closing_requested.emit(leader)
