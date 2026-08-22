class_name GameManager
extends Node

signal order_requested(recipe_id)

@onready var event_runner : EventRunner = $"../EventRunner"
@onready var dialogue_manager : DialogueManager = $"../DialogueManager"
@onready var customer_manager : CustomerManager = $"../CustomerManager"
@onready var typing_manager : TypingManager = $"../TypingManager"
@onready var profit_manager : ProfitManager = $"../ProfitManager"





@onready var customer_group_manager : CustomerGroupManager = $"../CustomerGroupManager"

@onready var day7_sequence_manager : Day7SequenceManager = $"../Day7SequenceManager"
@onready var cooking_sequence_manager : CookingSequenceManager = $"../CookingSequenceManager"
@onready var day_transition_manager : DayTransitionManager = $"../DayTransitionManager"
@onready var psychiatrist_sequence_manager : PsychiatristSequenceManager = $"../PsychiatristSequenceManager"
@onready var recipe_step_executor: RecipeStepExecutor = $"../RecipeStepExecutor"
@onready var plating: Plating = $"../../World/Plating"


var fake_typing_recipe := ""

## Sisa recipe_id yang masih harus dimasak buat 1 pesanan customer yang
## lagi jalan (recipe_id utama + semua additional_orders). Dipop satu-satu
## tiap kali 1 resep selesai -- customer baru "nerima makanan" & jalan ke
## meja kalau antrian ini udah bener-bener kosong.
var current_order_queue: Array[String] = []

var group_active: bool = false

var ending_active: bool = false

var active_customer_dialogue: Array[Dictionary] = []
var customer_dialogue_index: int = 0
var customer_dialogue_type: String = ""

@onready var sanity_manager : SanityManager = $"../SanityManager"
@onready var horror_manager : HorrorManager = $"../HorrorManager"
@onready var day_manager : DayManager = $"../DayManager"

@onready var player : Node3D = $"../../Player"
@onready var game_hud : GameHUD = $"../../UI/GameHUD"

@onready var horror_sequence_manager : HorrorSequenceManager = $"../HorrorSequenceManager"
@onready var ending_manager : EndingManager = $"../EndingManager"

func _ready():
	event_runner.event_started.connect(_on_event_started)
	event_runner.finished.connect(_on_day_finished)
	dialogue_manager.dialogue_finished.connect(_on_dialog_finished)

	customer_manager.customer_arrived.connect(_on_customer_arrived)
	
	customer_manager.customer_returned_to_cashier.connect(
		_on_customer_returned_to_cashier
	)

	customer_manager.customer_exited.connect(_on_customer_exited)
	
	profit_manager.profit_changed.connect(_on_profit_changed)
	cooking_sequence_manager.recipe_completed.connect(_on_cooking_recipe_completed)
	cooking_sequence_manager.step_started.connect(recipe_step_executor.execute_step)
	recipe_step_executor.step_completed.connect(cooking_sequence_manager.next_step)
	sanity_manager.horror_threshold_reached.connect(_on_horror_threshold_reached)
	
	
	
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
	
	day7_sequence_manager.sequence_finished.connect(
		_on_day7_sequence_finished
	)
	
	day_manager.day_started.connect(_on_day_started)
	day_manager.day_completed.connect(_on_day_completed)
	#day_manager.game_completed.connect(_on_game_completed)
	
	horror_sequence_manager.sequence_finished.connect(
		_on_horror_sequence_finished
	)
	
	call_deferred("start_day")
	


func _on_day7_sequence_finished() -> void:

	print("========================")
	print("GameManager menerima DAY 7 SEQUENCE SELESAI")
	print("========================")


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

	customer_manager.add_customers_served(
		group_count
	)

	print("========================")
	print("GameManager menerima: GROUP FINISHED")
	print(
		"Group customers served : ",
		group_count
	)
	print("========================")

	event_runner.next_event()





func _on_horror_threshold_reached(threshold: int) -> void:
	horror_manager.trigger_horror(threshold)

func _on_profit_changed(value: int) -> void:
	game_hud.update_profit(value)


func _on_cooking_recipe_completed(result: CookingResult) -> void:
	if result == null:
		return

	print("[GameManager] Cooking result: ", result.to_dict())

	var profit_delta := profit_manager.apply_cooking_result(result)
	sanity_manager.apply_profit_delta(profit_delta)

	# FIX BUG FATAL: take_recipe() sebelumnya TIDAK PERNAH dipanggil di
	# manapun, jadi Plating.is_occupied nyangkut true selamanya setelah
	# customer PERTAMA -- plate_recipe() customer KEDUA dst selalu gagal
	# (return false) secara diam-diam, bikin RecipeStepExecutor hang tanpa
	# error. Ini WAJIB dipanggil di sini, di LUAR pengecekan is_success(),
	# karena plate_recipe() sendiri juga dipanggil terlepas dari sukses/
	# gagalnya masakan (lihat RecipeStepExecutor baris ~163).
	if plating != null:
		plating.take_recipe()

	print(
		"[GameManager] Order ",
		result.recipe_id,
		" -> ",
		"SUCCESS" if result.is_success() else "FAILED"
	)

	_start_next_order_item()


## Proses antrian pesanan 1 customer satu per satu. Kalau masih ada
## recipe_id tersisa, masak itu berikutnya (nunggu recipe_completed lagi).
## Kalau sudah habis, BARU customer dianggap nerima SEMUA pesanannya dan
## jalan ke meja -- ini yang bikin pesanan 2 item (mis. "steak dan soda")
## keduanya benar-benar dimasak, bukan cuma yang pertama.
func _start_next_order_item() -> void:
	if not current_order_queue.is_empty():
		var next_recipe_id: String = current_order_queue.pop_front()

		print("[GameManager] Lanjut masak item berikutnya: ", next_recipe_id)

		cooking_sequence_manager.start_recipe(next_recipe_id)
		return

	# Antrian kosong -- semua item pesanan customer ini sudah dimasak & di-
	# plating. Ini menggantikan logic lama yang langsung receive_food()
	# begitu 1 resep selesai.
	if group_active:
		if customer_group_manager.current_customer != null:
			customer_group_manager.current_customer.receive_food()
			customer_group_manager.send_current_member_to_table()
	else:
		if customer_manager.current_customer != null:
			customer_manager.current_customer.receive_food()
			customer_manager.send_customer_to_table()
#func _input(event):
	#if event.is_action_pressed("ui_accept"):
		#sanity_manager.decrease_sanity(10)
#
	#if event.is_action_pressed("ui_cancel"):
		#sanity_manager.increase_sanity(10)

func start_day():

	print("===== DAY START =====")

	day_manager.start_day(1)

func _on_day_started(day: int) -> void:
	print("GameManager memulai Day ", day)

	var events = GameData.get_day_events(day)

	if events.is_empty():
		print("Belum ada event untuk Day ", day)
		return

	event_runner.start(events)

func _on_day_finished():
	day_manager.complete_day()

func _on_day_completed(day: int) -> void:
	print("GameManager menerima Day ", day, " selesai")
	day_transition_manager.start_day_transition(day)

func _on_customer_arrived():

	print("GameManager menerima: Customer sampai kasir")

	event_runner.next_event()


func _on_customer_exited():

	print("GameManager menerima: Customer keluar")

	event_runner.next_event()


func _on_dialog_finished():

	print("Dialogue selesai")

	if ending_active:
		print("Ending aktif -> EventRunner tidak dilanjutkan")
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

func _on_typing_finished():

	print("Typing selesai")

	if customer_manager.current_customer != null:
		customer_manager.current_customer.receive_food()

	customer_manager.send_customer_to_table()

func _on_customer_returned_to_cashier():

	print("GameManager menerima: Customer kembali ke kasir")

	if customer_manager.current_customer == null:
		return

	play_customer_dialogue(
		customer_manager.current_customer.get_closing_dialogue(),
		"closing"
	)

func _on_horror_sequence_finished() -> void:

	print("========================")
	print("GameManager menerima HORROR SEQUENCE SELESAI")
	print("========================")

	ending_active = true

	ending_manager.start_ending()

func _on_event_started(event):

	match event["type"]:

		"dialog":

			var target : Node3D = null

			if event["speaker"] == "customer":

				if customer_manager.current_customer != null:
					target = customer_manager.current_customer.get_node("Marker3D")

			elif event["speaker"] == "mc":

				target = player.get_node("DialogueMarker")

			dialogue_manager.start_dialog(event, target)


		#"typing":
#
			#if customer_manager.current_customer != null:
				#customer_manager.current_customer.start_waiting()
#
			#fake_typing_recipe = event["recipe"]
			#fake_typing_active = true
#
			#print("========================")
			#print("TYPING DIMULAI")
			#print("Recipe :", fake_typing_recipe)
			#print("========================")
		
		"typing":
			if group_active:
				if customer_group_manager.current_customer != null:
					var customer := customer_group_manager.current_customer
					customer.start_waiting()

					current_order_queue = [customer.get_recipe_id()]
					current_order_queue.append_array(customer.get_additional_orders())
					fake_typing_recipe = customer.get_recipe_id()

					print("========================")
					print("TYPING DIMULAI")
					print("Antrian pesanan :", current_order_queue)
					print("========================")

					_start_next_order_item()

			else:
				if customer_manager.current_customer != null:
					var customer := customer_manager.current_customer
					customer.start_waiting()

					current_order_queue = [customer.get_recipe_id()]
					current_order_queue.append_array(customer.get_additional_orders())
					fake_typing_recipe = customer.get_recipe_id()

					print("========================")
					print("TYPING DIMULAI")
					print("Antrian pesanan :", current_order_queue)
					print("========================")

					_start_next_order_item()

		"exit":
			print("Customer Exit")
			customer_manager.exit_customer()


		"spawn_customer":
			customer_manager.spawn_customer_by_id(
				event["customer_id"]
			)
		
		"spawn_group":
			customer_group_manager.start_group(
				event["group_id"]
			)
		
		"spawn_mika_day6":
			customer_manager.spawn_mika_day6()
		
		"mysterious_customer":
			day7_sequence_manager.play_day7_sequence()
		
		"customer_opening":
			if customer_manager.current_customer != null:
				play_customer_dialogue(
					customer_manager.current_customer.get_opening_dialogue(),
					"opening"
				)

#func play_customer_dialogue(
	#dialogues: Array[Dictionary]
#) -> void:
#
	#if dialogues.is_empty():
		#print("Tidak ada customer dialogue.")
		#event_runner.next_event()
		#return
#
	#active_customer_dialogue = dialogues
	#customer_dialogue_index = 0
#
	#show_next_customer_dialogue()

func show_customer_dialogue_line(dialog: Dictionary) -> void:

	var target: Node3D = null

	if dialog.get("speaker_type", "") == "customer":

		if group_active:

			if customer_group_manager.current_customer != null:
				target = customer_group_manager.current_customer.get_node("Marker3D")

		else:

			if customer_manager.current_customer != null:
				target = customer_manager.current_customer.get_node("Marker3D")

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


func start_group_typing() -> void:

	if customer_group_manager.current_customer == null:
		return

	var customer := customer_group_manager.current_customer

	customer.start_waiting()

	fake_typing_recipe = customer.get_recipe_id()

	cooking_sequence_manager.start_recipe(fake_typing_recipe)

	print("========================")
	print("GROUP TYPING DIMULAI")
	print("Customer :", customer.customer_name)
	print("Recipe :", fake_typing_recipe)
	print("========================")
