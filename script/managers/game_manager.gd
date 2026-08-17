class_name GameManager
extends Node

signal order_requested(recipe_id)

@onready var event_runner : EventRunner = $"../EventRunner"
@onready var dialogue_manager : DialogueManager = $"../DialogueManager"
@onready var customer_manager : CustomerManager = $"../CustomerManager"
@onready var typing_manager : TypingManager = $"../TypingManager"
@onready var profit_manager : ProfitManager = $"../ProfitManager"
@onready var day_transition_manager : DayTransitionManager = $"../DayTransitionManager"
@onready var psychiatrist_sequence_manager : PsychiatristSequenceManager = $"../PsychiatristSequenceManager"


var fake_typing_active := false
var fake_typing_recipe := ""

var ending_active: bool = false

var active_customer_dialogue: Array[Dictionary] = []
var customer_dialogue_index: int = 0
var customer_dialogue_type: String = ""

@onready var sanity_manager : SanityManager = $"../SanityManager"
@onready var horror_manager : HorrorManager = $"../HorrorManager"
@onready var day_manager : DayManager = $"../DayManager"

@onready var player : Node3D = $"../../PlayerBaru"
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
	
	sanity_manager.horror_threshold_reached.connect(_on_horror_threshold_reached)
	

	
	day_manager.day_started.connect(_on_day_started)
	day_manager.day_completed.connect(_on_day_completed)
	#day_manager.game_completed.connect(_on_game_completed)
	
	horror_sequence_manager.sequence_finished.connect(
		_on_horror_sequence_finished
	)
	
	call_deferred("start_day")
	

func _on_horror_threshold_reached(threshold: int) -> void:
	horror_manager.trigger_horror(threshold)

func _on_profit_changed(value: int) -> void:
	game_hud.update_profit(value)



	
#func _input(event):
	#if event.is_action_pressed("ui_accept"):
		#sanity_manager.decrease_sanity(10)
#
	#if event.is_action_pressed("ui_cancel"):
		#sanity_manager.increase_sanity(10)

func _input(event):

	if not fake_typing_active:
		return

	if event.is_action_pressed("ui_accept"):

		fake_typing_active = false

		print("========================")
		print("TYPING SELESAI")
		print("========================")

		# Sementara untuk testing:
		# setiap typing yang selesai dianggap berhasil
		profit_manager.customer_success()

		if customer_manager.current_customer != null:
			customer_manager.current_customer.receive_food()
			customer_manager.send_customer_to_table()

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
			if customer_manager.current_customer != null:
				customer_manager.current_customer.start_waiting()
				var recipe_id = customer_manager.current_customer.get_recipe_id()
				fake_typing_recipe = recipe_id
				fake_typing_active = true

				print("========================")
				print("TYPING DIMULAI")
				print("Recipe :", fake_typing_recipe)
				print("========================")



		"exit":
			print("Customer Exit")
			customer_manager.exit_customer()


		"spawn_customer":
			customer_manager.spawn_customer_by_id(
				event["customer_id"]
			)
		
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

		else:

			customer_dialogue_type = ""

			event_runner.next_event()

		return

	var dialog = active_customer_dialogue[customer_dialogue_index]

	customer_dialogue_index += 1

	dialogue_manager.start_dialog(dialog)
