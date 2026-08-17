class_name Customer
extends Node3D

signal arrived
signal returned_to_cashier
signal exited

enum State {
	SPAWNING,
	MOVING_TO_CASHIER,
	ORDERING,
	WAITING,
	RECEIVING,
	DINING,
	RETURNING_TO_CASHIER,
	LEAVING,
	DONE
}

var customer_name : String = ""
var state : State = State.SPAWNING
var profile: CustomerProfile = null


func setup_from_profile(new_profile: CustomerProfile) -> void:

	profile = new_profile
	customer_name = profile.character_name

	print("========================")
	print("CUSTOMER PROFILE")
	print("ID :", profile.character_id)
	print("Nama :", profile.character_name)
	print("Recipe :", profile.recipe_id)
	print("========================")

	setup_visual()

func setup_visual() -> void:

	var visual_root: Node3D = $Visual
	var placeholder: Node3D = visual_root.get_node_or_null("Placeholder")

	if profile.model_scene == null:
		print("Model belum tersedia untuk ", customer_name)
		return

	var model = profile.model_scene.instantiate()

	visual_root.add_child(model)

	if placeholder != null:
		placeholder.visible = false

	print("Model customer dipasang :", model.name)

func set_state(new_state : State):
	state = new_state

	print(
		customer_name,
		" STATE → ",
		State.keys()[state]
	)


func walk_to_cashier(target_position : Vector3):

	set_state(State.MOVING_TO_CASHIER)

	print(customer_name + " berjalan ke kasir")

	var tween = create_tween()

	tween.tween_property(
		self,
		"global_position",
		target_position,
		1.5
	)

	await tween.finished

	print(customer_name + " sudah sampai di kasir")

	set_state(State.ORDERING)

	arrived.emit()

func walk_to_table(
	target_position: Vector3,
	cashier_position: Vector3):

	set_state(State.DINING)

	print(customer_name + " berjalan ke meja")

	var tween = create_tween()

	tween.tween_property(
		self,
		"global_position",
		target_position,
		1.5
	)

	await tween.finished

	print(customer_name + " sudah sampai di meja")

	print(customer_name + " mulai makan")

	await get_tree().create_timer(5.0).timeout

	print(customer_name + " selesai makan")

	return_to_cashier(cashier_position)


func start_waiting():

	set_state(State.WAITING)

	print(customer_name + " sedang menunggu makanan")


func receive_food():

	set_state(State.RECEIVING)

	print(customer_name + " menerima makanan")

func return_to_cashier(target_position: Vector3):

	set_state(State.RETURNING_TO_CASHIER)

	print(customer_name + " kembali ke kasir")

	var tween = create_tween()

	tween.tween_property(
		self,
		"global_position",
		target_position,
		1.5
	)

	await tween.finished

	print(customer_name + " sudah kembali ke kasir")

	returned_to_cashier.emit()

func walk_out(target_position : Vector3):

	set_state(State.LEAVING)

	print(customer_name + " keluar restoran")

	var tween = create_tween()

	tween.tween_property(
		self,
		"global_position",
		target_position,
		1.5
	)

	await tween.finished

	print(customer_name + " sudah keluar")

	set_state(State.DONE)

	exited.emit()

	queue_free()


func get_opening_dialogue() -> Array[Dictionary]:

	if profile == null:
		print("Profile customer kosong.")
		return []

	print(
		"Opening dialogue ",
		customer_name,
		": ",
		profile.opening_dialogue.size()
	)

	return profile.opening_dialogue

func get_closing_dialogue() -> Array[Dictionary]:

	if profile == null:
		return []

	return profile.closing_dialogue

func get_recipe_id() -> String:

	if profile == null:
		return ""

	return profile.recipe_id	
