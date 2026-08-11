class_name GameManager
extends Node

signal order_requested(recipe_id)

@onready var event_runner : EventRunner = $"../EventRunner"
@onready var dialogue_manager : DialogueManager = $"../DialogueManager"
@onready var customer_manager : CustomerManager = $"../CustomerManager"
@onready var typing_manager : TypingManager = $"../TypingManager"
@onready var profit_manager : ProfitManager = $"../ProfitManager"


@onready var sanity_manager : SanityManager = $"../SanityManager"
@onready var horror_manager : HorrorManager = $"../HorrorManager"
@onready var day_manager : DayManager = $"../DayManager"

@onready var player : Node3D = $"../../PlayerBaru"
@onready var game_hud : GameHUD = $"../../UI/GameHUD"

func _ready():

	event_runner.event_started.connect(_on_event_started)

	event_runner.finished.connect(_on_day_finished)

	dialogue_manager.dialogue_finished.connect(_on_dialog_finished)

	

	customer_manager.customer_arrived.connect(_on_customer_arrived)

	customer_manager.customer_exited.connect(_on_customer_exited)
	
	profit_manager.profit_changed.connect(_on_profit_changed)
	
	sanity_manager.horror_threshold_reached.connect(_on_horror_threshold_reached)
	

	
	day_manager.day_started.connect(_on_day_started)
	day_manager.day_completed.connect(_on_day_completed)
	#day_manager.game_completed.connect(_on_game_completed)

	call_deferred("start_day")
	

func _on_horror_threshold_reached(threshold: int) -> void:
	horror_manager.trigger_horror(threshold)

func _on_profit_changed(value: int) -> void:
	game_hud.update_profit(value)



	
func _input(event):
	if event.is_action_pressed("ui_accept"):
		sanity_manager.decrease_sanity(10)

	if event.is_action_pressed("ui_cancel"):
		sanity_manager.increase_sanity(10)

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

	day_manager.next_day()

func _on_customer_arrived():

	print("GameManager menerima: Customer sampai kasir")

	event_runner.next_event()


func _on_customer_exited():

	print("GameManager menerima: Customer keluar")

	event_runner.next_event()


func _on_dialog_finished():

	print("Dialogue selesai")

	event_runner.next_event()



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


		"typing":

			print("Recipe dimulai: ", event["recipe"])



		"exit":

			print("Customer Exit")

			customer_manager.exit_customer()


		"spawn_customer":

			customer_manager.spawn_customer(event["name"])
