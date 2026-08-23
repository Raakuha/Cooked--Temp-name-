class_name GameManager
extends Node

signal order_requested(recipe_id)


@onready var event_runner: EventRunner = $"../EventRunner"
@onready var dialogue_manager: DialogueManager = $"../DialogueManager"
@onready var customer_manager: CustomerManager = $"../CustomerManager"
@onready var typing_manager: TypingManager = $"../TypingManager"
@onready var profit_manager: ProfitManager = $"../ProfitManager"
@onready var menu_deadline_timer: MenuDeadlineTimer = $"../MenuDeadlineTimer"
@onready var customer_group_manager: CustomerGroupManager = $"../CustomerGroupManager"

@onready var day7_sequence_manager: Day7SequenceManager = $"../Day7SequenceManager"
@onready var cooking_sequence_manager: CookingSequenceManager = $"../CookingSequenceManager"
@onready var day_transition_manager: DayTransitionManager = $"../DayTransitionManager"
@onready var psychiatrist_sequence_manager: PsychiatristSequenceManager = $"../PsychiatristSequenceManager"
@onready var recipe_step_executor: RecipeStepExecutor = $"../RecipeStepExecutor"
@onready var plating: Plating = $"../../World/Plating"

@onready var sanity_manager: SanityManager = $"../SanityManager"
@onready var horror_manager: HorrorManager = $"../HorrorManager"
@onready var day_manager: DayManager = $"../DayManager"

@onready var player: Node3D = $"../../Player"
@onready var game_hud: GameHUD = $"../../UI/GameHUD"

@onready var horror_sequence_manager: HorrorSequenceManager = $"../HorrorSequenceManager"
@onready var ending_manager: EndingManager = $"../EndingManager"

@onready var police_opening_manager : PoliceOpeningManager = $"../PoliceOpeningManager"

@onready var tutorial_sequence_manager : TutorialSequenceManager = $"../TutorialSequenceManager"

var opening_finished: bool = false


# Recipe yang sedang dijalankan / recipe terakhir yang dijalankan.
var fake_typing_recipe: String = ""
var order_deadline_missed: bool = false
# Antrean semua pesanan customer aktif.
# Contoh:
# ["roti_khas_lempuyangan", "soda", "soda", "steak", "salad"]
var current_order_queue: Array[String] = []

var group_active: bool = false
var ending_active: bool = false

var active_customer_dialogue: Array[Dictionary] = []
var customer_dialogue_index: int = 0
var customer_dialogue_type: String = ""






func _ready() -> void:
	event_runner.event_started.connect(_on_event_started)
	event_runner.finished.connect(_on_day_finished)

	dialogue_manager.dialogue_finished.connect(_on_dialog_finished)

	customer_manager.customer_arrived.connect(_on_customer_arrived)
	customer_manager.customer_returned_to_cashier.connect(
		_on_customer_returned_to_cashier
	)
	menu_deadline_timer.deadline_expired.connect(
		_on_order_deadline_expired
	)
	customer_manager.customer_exited.connect(_on_customer_exited)

	profit_manager.profit_changed.connect(_on_profit_changed)

	# Cooking flow
	cooking_sequence_manager.recipe_completed.connect(
		_on_cooking_recipe_completed
	)

	cooking_sequence_manager.step_started.connect(
		recipe_step_executor.execute_step
	)

	recipe_step_executor.step_completed.connect(
		cooking_sequence_manager.next_step
	)
	recipe_step_executor.step_cancelled.connect(
		cooking_sequence_manager.cancel_current_prep
	)


	sanity_manager.horror_threshold_reached.connect(_on_horror_threshold_reached)

	police_opening_manager.sequence_finished.connect(
		_on_police_opening_finished
	)

	tutorial_sequence_manager.tutorial_finished.connect(
		_on_tutorial_finished
	)

	recipe_step_executor.step_cancelled.connect(
	_on_recipe_step_cancelled
)

	sanity_manager.horror_threshold_reached.connect(
		_on_horror_threshold_reached
	)

	# Group customer flow
	customer_group_manager.group_started.connect(
		_on_group_started
	)

	customer_group_manager.member_arrived.connect(
		_on_group_member_arrived
	)

	customer_group_manager.group_finished.connect(
		_on_group_finished
	)

	customer_group_manager.group_closing_requested.connect(
		_on_group_closing_requested
	)

	# Day 7
	day7_sequence_manager.sequence_finished.connect(
		_on_day7_sequence_finished
	)

	# Day flow
	day_manager.day_started.connect(_on_day_started)
	day_manager.day_completed.connect(_on_day_completed)

	# Horror
	horror_sequence_manager.sequence_finished.connect(
		_on_horror_sequence_finished
	)

	call_deferred("start_opening")


func start_opening() -> void:

	print("========================")
	print("GAME OPENING")
	print("========================")

	police_opening_manager.play_opening()




func _on_police_opening_finished() -> void:

	print("========================")
	print("POLICE OPENING FINISHED")
	print("========================")

	opening_finished = true

	tutorial_sequence_manager.play_tutorial()

func _on_tutorial_finished() -> void:

	print("========================")
	print("TUTORIAL FINISHED")
	print("========================")

	start_day()

func _on_day7_sequence_finished() -> void:
	print("========================")
	print("GameManager menerima DAY 7 SEQUENCE SELESAI")
	print("========================")


# =========================================================
# GROUP CUSTOMER
# =========================================================

func _on_group_closing_requested(customer: Customer) -> void:
	print("========================")
	print(
		"GameManager menerima GROUP CLOSING -> ",
		customer.customer_name
	)
	print("========================")

	play_customer_dialogue(
		customer.get_closing_dialogue(),
		"group_closing"
	)


func _on_group_started() -> void:
	group_active = true

	print("========================")
	print("GameManager menerima: GROUP STARTED")
	print("========================")


func _on_group_member_arrived(customer: Customer) -> void:
	print("========================")
	print(
		"GameManager menerima GROUP MEMBER ARRIVED -> ",
		customer.customer_name
	)
	print("========================")

	play_customer_dialogue(
		customer.get_opening_dialogue(),
		"group_opening"
	)


func _on_group_finished() -> void:
	group_active = false

	var group_count := customer_group_manager.last_group_member_count

	customer_manager.add_customers_served(group_count)

	print("========================")
	print("GameManager menerima: GROUP FINISHED")
	print(
		"Group customers served : ",
		group_count
	)
	print("========================")

	event_runner.next_event()


# =========================================================
# HORROR / PROFIT
# =========================================================

func _on_horror_threshold_reached(threshold: int) -> void:
	horror_manager.trigger_horror(threshold)


func _on_profit_changed(value: int) -> void:
	game_hud.update_profit(value)


# =========================================================
# COOKING COMPLETED
# =========================================================

func _on_cooking_recipe_completed(result: CookingResult) -> void:

	if result == null:
		return

	# =========================================
	# TUTORIAL POLISI
	# =========================================

	if tutorial_sequence_manager.active:

		print("========================")
		print("[GameManager] Recipe selesai saat tutorial.")
		print("Recipe :", result.recipe_id)
		print("========================")

		if plating != null:
			plating.take_recipe()

		return


	# =========================================
	# CUSTOMER COOKING
	# =========================================

	print("[GameManager] Cooking result: ", result.to_dict())

	var profit_delta := profit_manager.apply_cooking_result(result)
	sanity_manager.apply_profit_delta(profit_delta)

	if plating != null:
		plating.take_recipe()

	print(
		"[GameManager] Order ",
		result.recipe_id,
		" -> ",
		"SUCCESS" if result.is_success() else "FAILED"
	)

	_start_next_order_item()

# =========================================================
# ORDER QUEUE
# =========================================================

func _start_next_order_item() -> void:

	# =====================================================
	# MASIH ADA ORDER YANG HARUS DIKERJAKAN
	# =====================================================
	if not current_order_queue.is_empty():

		var next_recipe_id: String = current_order_queue.pop_front()

		fake_typing_recipe = next_recipe_id

		# Beri tahu RecipeStepExecutor recipe yang sedang dikerjakan.
		recipe_step_executor.set_recipe_name(next_recipe_id)

		print("========================")
		print("[GameManager] MULAI ORDER BERIKUTNYA")
		print("Recipe :", next_recipe_id)
		print("Sisa antrian :", current_order_queue)
		print("========================")

		# Kalau deadline sudah terlewat sebelumnya,
		# recipe berikutnya tetap dikerjakan,
		# tetapi langsung ditandai gagal.
		if order_deadline_missed:
			cooking_sequence_manager.mark_deadline_expired()

		cooking_sequence_manager.start_recipe(next_recipe_id)

		return


	# =====================================================
	# QUEUE KOSONG
	# SEMUA ORDER CUSTOMER SUDAH SELESAI
	# =====================================================

	print("========================")
	print("[GameManager] SEMUA ORDER SELESAI")
	print("========================")
	menu_deadline_timer.stop_order()


	if group_active:

		if customer_group_manager.current_customer != null:
			customer_group_manager.current_customer.receive_food()
			customer_group_manager.send_current_member_to_table()

	else:

		if customer_manager.current_customer != null:
			customer_manager.current_customer.receive_food()
			customer_manager.send_customer_to_table()
# =========================================================
# DAY FLOW
# =========================================================

func start_day() -> void:
	print("===== DAY START =====")

	day_manager.start_day(1)

func _on_day_started(day: int) -> void:
	print("GameManager memulai Day ", day)

	var events = GameData.get_day_events(day)

	if events.is_empty():
		print("Belum ada event untuk Day ", day)
		return

	event_runner.start(events)


func _on_day_finished() -> void:
	day_manager.complete_day()


func _on_day_completed(day: int) -> void:
	print("GameManager menerima Day ", day, " selesai")

	day_transition_manager.start_day_transition(day)


# =========================================================
# CUSTOMER FLOW
# =========================================================

func _on_customer_arrived() -> void:
	print("GameManager menerima: Customer sampai kasir")

	event_runner.next_event()


func _on_customer_exited() -> void:
	print("GameManager menerima: Customer keluar")

	event_runner.next_event()


# =========================================================
# DIALOGUE
# =========================================================

func _on_dialog_finished() -> void:
	print("Dialogue selesai")

	if ending_active:
		print("Ending aktif -> EventRunner tidak dilanjutkan")
		return

	if police_opening_manager.active:
		print("Police opening aktif -> EventRunner tidak dilanjutkan")
		return

	if tutorial_sequence_manager.active:
		print("Tutorial aktif -> EventRunner tidak dilanjutkan")
		return

	if psychiatrist_sequence_manager.active:
		print("Psychiatrist sequence aktif -> EventRunner tidak dilanjutkan")
		return

	if day_transition_manager.profit_dialogue_active:
		print("Profit dialogue aktif -> EventRunner tidak dilanjutkan")
		return

	if day7_sequence_manager.active:
		print("Day 7 sequence aktif -> EventRunner tidak dilanjutkan")
		return

	if not active_customer_dialogue.is_empty():
		show_next_customer_dialogue()
		return

	event_runner.next_event()


# =========================================================
# TYPING FINISHED
# =========================================================
# Logic lama receive_food() sengaja tidak dipakai lagi.
# Penyelesaian customer sekarang ditangani oleh
# _start_next_order_item() ketika queue benar-benar kosong.
#
# Fungsi dibiarkan supaya aman apabila masih ada koneksi lama.
# =========================================================

func _on_typing_finished() -> void:
	print("Typing selesai -> penyelesaian customer ditangani oleh order queue")


# =========================================================
# CUSTOMER RETURNING TO CASHIER
# =========================================================

func _on_customer_returned_to_cashier() -> void:
	print("GameManager menerima: Customer kembali ke kasir")

	if customer_manager.current_customer == null:
		return

	play_customer_dialogue(
		customer_manager.current_customer.get_closing_dialogue(),
		"closing"
	)


# =========================================================
# HORROR SEQUENCE
# =========================================================

func _on_horror_sequence_finished() -> void:
	print("========================")
	print("GameManager menerima HORROR SEQUENCE SELESAI")
	print("========================")

	ending_active = true

	ending_manager.start_ending()


# =========================================================
# EVENT STARTED
# =========================================================

func _on_event_started(event) -> void:

	match event["type"]:

		# ---------------------------------------------------
		# DIALOG
		# ---------------------------------------------------
		"dialog":
			var target: Node3D = null

			if event["speaker"] == "customer":

				if customer_manager.current_customer != null:
					target = customer_manager.current_customer.get_node(
						"Marker3D"
					)

			elif event["speaker"] == "mc":

				target = player.get_node("DialogueMarker")

			dialogue_manager.start_dialog(event, target)


		# ---------------------------------------------------
		# TYPING / COOKING
		# ---------------------------------------------------
		"typing":

			# ===============================================
			# GROUP CUSTOMER
			# ===============================================

			if group_active:

				if customer_group_manager.current_customer != null:
					var customer: Customer = (
						customer_group_manager.current_customer
					)

					customer.start_waiting()

					current_order_queue.clear()

					current_order_queue.append(
						customer.get_recipe_id()
					)

					current_order_queue.append_array(
						customer.get_additional_orders()
					)

					print("========================")
					print("GROUP TYPING DIMULAI")
					print("Customer :", customer.customer_name)
					print(
						"Antrian pesanan : ",
						current_order_queue
					)
					print("========================")

					_start_next_order_item()


			# ===============================================
			# NORMAL CUSTOMER
			# ===============================================

			else:
				if customer_manager.current_customer != null:
					var customer: Customer = (
						customer_manager.current_customer
					)

					customer.start_waiting()

					current_order_queue.clear()
					current_order_queue.append(
						customer.get_recipe_id()
					)

					current_order_queue.append_array(
						customer.get_additional_orders()
					)

					order_deadline_missed = false

					var total_deadline := _calculate_order_deadline()

					print("========================")
					print("TYPING DIMULAI")
					print("Customer :", customer.customer_name)
					print("Antrian pesanan : ", current_order_queue)
					print("Total deadline : ", total_deadline)
					print("========================")

					menu_deadline_timer.start_order(total_deadline)

					_start_next_order_item()
		# ---------------------------------------------------
		# EXIT
		# ---------------------------------------------------
		"exit":
			print("Customer Exit")

			customer_manager.exit_customer()


		# ---------------------------------------------------
		# SPAWN CUSTOMER
		# ---------------------------------------------------
		"spawn_customer":
			customer_manager.spawn_customer_by_id(
				event["customer_id"]
			)


		# ---------------------------------------------------
		# SPAWN GROUP
		# ---------------------------------------------------
		"spawn_group":
			customer_group_manager.start_group(
				event["group_id"]
			)


		# ---------------------------------------------------
		# MIKA DAY 6
		# ---------------------------------------------------
		"spawn_mika_day6":
			customer_manager.spawn_mika_day6()


		# ---------------------------------------------------
		# MYSTERIOUS CUSTOMER
		# ---------------------------------------------------
		"mysterious_customer":
			day7_sequence_manager.play_day7_sequence()


		# ---------------------------------------------------
		# CUSTOMER OPENING
		# ---------------------------------------------------
		"customer_opening":

			if customer_manager.current_customer != null:
				play_customer_dialogue(
					customer_manager.current_customer.get_opening_dialogue(),
					"opening"
				)


# =========================================================
# CUSTOMER DIALOGUE
# =========================================================

func show_customer_dialogue_line(dialog: Dictionary) -> void:

	var target: Node3D = null

	if dialog.get("speaker_type", "") == "customer":

		if group_active:

			if customer_group_manager.current_customer != null:
				target = customer_group_manager.current_customer.get_node(
					"Marker3D"
				)

		else:

			if customer_manager.current_customer != null:
				target = customer_manager.current_customer.get_node(
					"Marker3D"
				)

	elif dialog.get("speaker_type", "") == "mc":

		target = player.get_node("DialogueMarker")

	dialogue_manager.start_dialog(dialog, target)


func play_customer_dialogue(
	dialogues: Array[Dictionary],
	dialogue_type: String
) -> void:

	print("========================")
	print("CUSTOMER DIALOGUE")
	print("Type :", dialogue_type)
	print("Jumlah dialogue :", dialogues.size())
	print("========================")

	if dialogues.is_empty():

		print("Tidak ada customer dialogue.")

		if dialogue_type == "closing":
			customer_manager.exit_customer()
		else:
			event_runner.next_event()

		return

	active_customer_dialogue = dialogues
	customer_dialogue_index = 0
	customer_dialogue_type = dialogue_type

	show_next_customer_dialogue()


func show_next_customer_dialogue() -> void:

	if customer_dialogue_index >= active_customer_dialogue.size():

		active_customer_dialogue.clear()
		customer_dialogue_index = 0

		print(
			"Customer dialogue selesai -> ",
			customer_dialogue_type
		)

		if customer_dialogue_type == "closing":

			customer_dialogue_type = ""

			customer_manager.exit_customer()


		elif customer_dialogue_type == "group_closing":

			customer_dialogue_type = ""

			customer_group_manager.exit_group()


		elif customer_dialogue_type == "group_opening":

			customer_dialogue_type = ""

			start_group_typing()


		else:

			customer_dialogue_type = ""

			event_runner.next_event()

		return

	var dialog = active_customer_dialogue[customer_dialogue_index]

	customer_dialogue_index += 1

	show_customer_dialogue_line(dialog)


# =========================================================
# GROUP TYPING
# =========================================================

func start_group_typing() -> void:

	if customer_group_manager.current_customer == null:
		return

	var customer: Customer = (
		customer_group_manager.current_customer
	)

	customer.start_waiting()

	current_order_queue.clear()

	current_order_queue.append(
		customer.get_recipe_id()
	)

	current_order_queue.append_array(
		customer.get_additional_orders()
	)

	# ==========================================
	# MULAI DEADLINE UNTUK SELURUH ORDER
	# ==========================================
	order_deadline_missed = false

	var total_deadline := _calculate_order_deadline()

	print("========================")
	print("GROUP TYPING DIMULAI")
	print("Customer :", customer.customer_name)
	print("Antrian pesanan :", current_order_queue)
	print("Total deadline :", total_deadline, " detik")
	print("========================")

	menu_deadline_timer.start_order(total_deadline)

	_start_next_order_item()
func _on_recipe_step_cancelled() -> void:
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	print("[GM] STEP CANCELLED DITERIMA")
	print("[GM] memanggil cancel_current_prep()")
	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")

	cooking_sequence_manager.cancel_current_prep()
func _on_order_deadline_expired() -> void:
	print("[GameManager] SIGNAL DEADLINE DITERIMA")

	order_deadline_missed = true

	cooking_sequence_manager.mark_deadline_expired()
func _calculate_order_deadline() -> float:
	var total: float = 0.0

	for recipe_id in current_order_queue:
		total += menu_deadline_timer.get_deadline_for(recipe_id)

	return total
