class_name Customer
extends Node3D

signal arrived
signal returned_to_cashier
signal exited
signal group_move_finished
signal table_arrived
signal dining_finished

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

var animation_player: AnimationPlayer = null

var use_day6_variant: bool = false

func set_day6_variant() -> void:

	use_day6_variant = true


func get_day6_opening_dialogue() -> Array[Dictionary]:

	if profile == null:
		return []

	return profile.day6_opening_dialogue

func get_day6_recipe_id() -> String:

	if profile == null:
		return ""

	return profile.day6_recipe_id

func get_day6_closing_dialogue() -> Array[Dictionary]:

	if profile == null:
		return []

	return profile.day6_closing_dialogue




func walk_to_group_wait(target_position: Vector3) -> void:

	set_state(State.MOVING_TO_CASHIER)

	print(
		customer_name,
		" berjalan bersama grup"
	)

	play_walk_animation()

	var tween := create_tween()

	tween.tween_property(
		self,
		"global_position",
		target_position,
		1.5
	)

	await tween.finished

	play_idle_animation()

	print(
		customer_name,
		" sampai area tunggu grup"
	)

	set_state(State.WAITING)

	group_move_finished.emit()



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

	if profile == null:
		return

	if profile.model_scene == null:

		print(
			"Model belum tersedia untuk ",
			customer_name
		)

		if placeholder != null:
			placeholder.visible = true

		return

	var model := profile.model_scene.instantiate()

	visual_root.add_child(model)

	if placeholder != null:
		placeholder.visible = false

	animation_player = model.find_child(
		"AnimationPlayer",
		true,
		false
	) as AnimationPlayer

	print(
		"Model customer dipasang : ",
		model.name
	)

	if animation_player != null:

		print(
			"AnimationPlayer ditemukan untuk ",
			customer_name
		)

	else:

		print(
			"AnimationPlayer belum tersedia untuk ",
			customer_name
		)

func set_state(new_state : State):
	state = new_state

	print(
		customer_name,
		" STATE → ",
		State.keys()[state]
	)


func play_animation(animation_name: String) -> void:

	if animation_player == null:

		print(
			customer_name,
			": AnimationPlayer tidak ditemukan."
		)

		return

	if not animation_player.has_animation(animation_name):

		print(
			customer_name,
			": Animasi tidak ditemukan -> ",
			animation_name
		)

		return

	animation_player.play(animation_name)


func play_idle_animation() -> void:

	play_animation("Idle")


func play_walk_animation() -> void:

	play_animation("Walk")


func play_celebrate_animation() -> void:

	play_animation("Celebrate")



func play_celebration() -> void:

	if animation_player == null:

		print(
			customer_name,
			": AnimationPlayer tidak ditemukan."
		)

		return

	if not animation_player.has_animation("Celebrate"):

		print(
			customer_name,
			": Animasi Celebrate belum tersedia."
		)

		return

	print(
		customer_name,
		": CELEBRATE START"
	)

	animation_player.play("Celebrate")

	await animation_player.animation_finished

	print(
		customer_name,
		": CELEBRATE FINISHED"
	)



func walk_to_cashier(target_position: Vector3) -> void:

	set_state(State.MOVING_TO_CASHIER)

	print(
		customer_name,
		" berjalan ke kasir"
	)

	play_walk_animation()

	var tween := create_tween()

	tween.tween_property(
		self,
		"global_position",
		target_position,
		1.5
	)

	await tween.finished

	play_idle_animation()

	print(
		customer_name,
		" sudah sampai di kasir"
	)

	set_state(State.ORDERING)

	arrived.emit()



func walk_to_table(
	target_position: Vector3,
	cashier_position: Vector3,
	auto_return: bool = true
) -> void:

	set_state(State.DINING)

	print(
		customer_name,
		" berjalan ke meja"
	)

	play_walk_animation()

	var tween := create_tween()

	tween.tween_property(
		self,
		"global_position",
		target_position,
		1.5
	)

	await tween.finished

	play_idle_animation()

	print(
		customer_name,
		" sudah sampai di meja"
	)

	table_arrived.emit()

	print(
		customer_name,
		" mulai makan"
	)

	await get_tree().create_timer(5.0).timeout

	print(
		customer_name,
		" selesai makan"
	)

	dining_finished.emit()

	if auto_return:
		return_to_cashier(cashier_position)




func start_waiting():

	set_state(State.WAITING)

	print(customer_name + " sedang menunggu makanan")


func receive_food() -> void:

	set_state(State.RECEIVING)

	print(
		customer_name,
		" menerima makanan"
	)

	await play_celebration()

	set_state(State.RECEIVING)

	print(
		customer_name,
		" selesai menerima makanan"
	)

func return_to_cashier(target_position: Vector3) -> void:

	set_state(State.RETURNING_TO_CASHIER)

	print(
		customer_name,
		" kembali ke kasir"
	)

	play_walk_animation()

	var tween := create_tween()

	tween.tween_property(
		self,
		"global_position",
		target_position,
		1.5
	)

	await tween.finished

	play_idle_animation()

	print(
		customer_name,
		" sudah kembali ke kasir"
	)

	returned_to_cashier.emit()



func walk_out(target_position: Vector3) -> void:

	set_state(State.LEAVING)

	print(
		customer_name,
		" keluar restoran"
	)

	play_walk_animation()

	var tween := create_tween()

	tween.tween_property(
		self,
		"global_position",
		target_position,
		1.5
	)

	await tween.finished

	play_idle_animation()

	print(
		customer_name,
		" sudah keluar"
	)

	set_state(State.DONE)

	exited.emit()

	queue_free()


func get_opening_dialogue() -> Array[Dictionary]:

	if profile == null:
		print("Profile customer kosong.")
		return []
	
	
	if use_day6_variant:
		return profile.day6_opening_dialogue
	
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

	if use_day6_variant:
		return profile.day6_closing_dialogue

	return profile.closing_dialogue

func get_recipe_id() -> String:

	if profile == null:
		return ""

	if use_day6_variant:
		return profile.day6_recipe_id

	return profile.recipe_id


## Barang tambahan yang dipesan bareng recipe_id utama (mis. minuman).
## Dipanggil GameManager buat bikin antrian pesanan lengkap 1 customer.
func get_additional_orders() -> Array[String]:

	if profile == null:
		return []

	if use_day6_variant:
		return profile.day6_additional_orders

	return profile.additional_orders
