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

@export var move_speed: float = 3.5


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


func move_to_position(target_position: Vector3) -> void:

	var distance: float = global_position.distance_to(target_position)

	if distance <= 0.01:
		play_idle_animation()
		return

	face_target(target_position)

	var duration: float = distance / move_speed

	play_walk_animation()

	var tween := create_tween()

	tween.tween_property(
		self,
		"global_position",
		target_position,
		duration
	)

	await tween.finished

	play_idle_animation()



func face_target(target_position: Vector3) -> void:

	var direction: Vector3 = target_position - global_position
	direction.y = 0.0

	if direction.length_squared() <= 0.0001:
		return

	rotation.y = atan2(
		-direction.x,
		-direction.z
	)

func set_animation_loop(animation_name: String, should_loop: bool) -> void:

	if animation_player == null:
		return

	if not animation_player.has_animation(animation_name):
		return

	var animation := animation_player.get_animation(animation_name)

	if should_loop:
		animation.loop_mode = Animation.LOOP_LINEAR
	else:
		animation.loop_mode = Animation.LOOP_NONE

func walk_to_group_wait(target_position: Vector3) -> void:

	set_state(State.MOVING_TO_CASHIER)

	print(
		customer_name,
		" berjalan bersama grup"
	)

	await move_to_position(target_position)

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

		print(
			"Animasi tersedia untuk ",
			customer_name,
			": ",
			animation_player.get_animation_list()
		)

		play_idle_animation()

	else:

		print(
			customer_name,
			": AnimationPlayer belum tersedia untuk ",
			customer_name
		)

func set_state(new_state : State):
	state = new_state

	print(
		customer_name,
		" STATE → ",
		State.keys()[state]
	)


func play_animation(animation_name: String) -> bool:

	if animation_player == null:
		print(
			customer_name,
			": AnimationPlayer tidak ditemukan."
		)
		return false

	print(
		customer_name,
		": Request animasi -> ",
		animation_name
	)

	if not animation_player.has_animation(animation_name):
		print(
			customer_name,
			": Animasi tidak ditemukan -> ",
			animation_name
		)
		return false

	var should_loop := (
		animation_name == "Idle"
		or animation_name == "idle"
		or animation_name == "Walk"
		or animation_name == "walk"
	)

	var animation := animation_player.get_animation(animation_name)

	if should_loop:
		animation.loop_mode = Animation.LOOP_LINEAR
	else:
		animation.loop_mode = Animation.LOOP_NONE

	if animation_player.current_animation == animation_name:
		return true

	animation_player.play(animation_name)

	return true


func play_idle_animation() -> void:

	if play_animation("Idle"):
		return

	play_animation("idle")


func play_walk_animation() -> void:

	if play_animation("Walk"):
		return

	play_animation("walk")


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



func play_animation_and_wait(animation_name: String) -> bool:

	if animation_player == null:

		print(
			customer_name,
			": AnimationPlayer tidak ditemukan."
		)

		return false

	if not animation_player.has_animation(animation_name):

		print(
			customer_name,
			": Animasi tidak ditemukan -> ",
			animation_name
		)

		return false

	var animation := animation_player.get_animation(
		animation_name
	)

	# Animasi seperti Duduk, Makan, dan TurunKursi
	# dijalankan satu kali.
	animation.loop_mode = Animation.LOOP_NONE

	print(
		customer_name,
		": PLAY -> ",
		animation_name
	)

	animation_player.play(animation_name)

	await animation_player.animation_finished

	print(
		customer_name,
		": FINISHED -> ",
		animation_name
	)

	return true


func play_dining_sequence() -> void:

	print("========================")
	print(
		customer_name,
		": DINING ANIMATION START"
	)
	print("========================")


	# =========================================
	# DUDUK
	# =========================================

	var sat_down := await play_animation_and_wait(
		"Duduk"
	)

	if not sat_down:
		print(
			customer_name,
			": Gagal memainkan animasi Duduk."
		)

		return


	# =========================================
	# MAKAN
	# =========================================

	var ate := await play_animation_and_wait(
		"Makan"
	)

	if not ate:
		print(
			customer_name,
			": Gagal memainkan animasi Makan."
		)

		return


	# =========================================
	# TURUN KURSI / BERDIRI
	# =========================================

	var stood_up := await play_animation_and_wait(
		"TurunKursi"
	)

	if not stood_up:
		print(
			customer_name,
			": Gagal memainkan animasi TurunKursi."
		)

		return


	# =========================================
	# SELESAI
	# =========================================

	play_idle_animation()

	print("========================")
	print(
		customer_name,
		": DINING ANIMATION FINISHED"
	)
	print("========================")



func walk_to_cashier(target_position: Vector3) -> void:

	set_state(State.MOVING_TO_CASHIER)

	print(
		customer_name,
		" berjalan ke kasir"
	)

	await move_to_position(target_position)

	print(
		customer_name,
		" sudah sampai di kasir"
	)

	set_state(State.ORDERING)

	arrived.emit()



func walk_to_table(
	approach_position: Vector3,
	sit_transform: Transform3D,
	exit_position: Vector3,
	cashier_position: Vector3,
	auto_return: bool = true
) -> void:

	set_state(State.DINING)

	print(
		customer_name,
		" berjalan menuju meja"
	)

	# =========================================
	# MENUJU DEPAN KURSI
	# =========================================

	await move_to_position(
		approach_position
	)

	print(
		customer_name,
		" sampai ApproachPoint"
	)

	# =========================================
	# POSISI AWAL DUDUK
	# =========================================

	global_transform = sit_transform

	table_arrived.emit()

	# =========================================
	# DUDUK → MAKAN → TURUN KURSI
	# =========================================

	await play_dining_sequence()

	print(
		customer_name,
		" selesai makan"
	)

	dining_finished.emit()

	# =========================================
	# KELUAR DARI KURSI
	# =========================================

	if auto_return:

		print(
			customer_name,
			" keluar dari kursi"
		)

		await move_to_position(
			exit_position
		)

		print(
			customer_name,
			" sudah keluar dari area kursi"
		)

		# =====================================
		# KEMBALI KE KASIR
		# =====================================

		await return_to_cashier(
			cashier_position
		)



func start_waiting():

	set_state(State.WAITING)
	play_idle_animation()

	print(customer_name + " sedang menunggu makanan")


func receive_food() -> void:

	set_state(State.RECEIVING)

	print(
		customer_name,
		" menerima makanan"
	)

	var approved_played := play_approved_animation()

	if approved_played and animation_player != null:
		await animation_player.animation_finished

	play_idle_animation()

	print(
		customer_name,
		" selesai menerima makanan"
	)


func play_approved_animation() -> bool:

	if play_animation("AnimasiApproved_1"):
		return true

	if play_animation("Celebrate"):
		return true

	return false

func return_to_cashier(target_position: Vector3) -> void:

	set_state(State.RETURNING_TO_CASHIER)

	print(
		customer_name,
		" kembali ke kasir"
	)

	await move_to_position(target_position)

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

	await move_to_position(target_position)

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
