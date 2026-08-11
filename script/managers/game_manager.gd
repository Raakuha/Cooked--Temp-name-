class_name GameManager
extends Node

signal order_requested(recipe_id)

@onready var event_runner : EventRunner = $"../EventRunner"
@onready var dialogue_manager : DialogueManager = $"../DialogueManager"
@onready var customer_manager : CustomerManager = $"../CustomerManager"
@onready var typing_manager : TypingManager = $"../TypingManager"
@onready var profit_manager : ProfitManager = $"../ProfitManager"
@onready var sanity_manager : SanityManager = $"../SanityManager"

@onready var player : Node3D = $"../../PlayerBaru"
@onready var game_hud : GameHUD = $"../../UI/GameHUD"

func _ready():

	event_runner.event_started.connect(_on_event_started)

	event_runner.finished.connect(_on_day_finished)

	dialogue_manager.dialogue_finished.connect(_on_dialog_finished)

	typing_manager.typing_finished.connect(_on_typing_finished)

	customer_manager.customer_arrived.connect(_on_customer_arrived)

	customer_manager.customer_exited.connect(_on_customer_exited)
	
	profit_manager.profit_changed.connect(_on_profit_changed)
	

	call_deferred("start_day")
	
func _on_profit_changed(value: int) -> void:
	game_hud.update_profit(value)


	
func _input(event):
	if event.is_action_pressed("ui_accept"):
		sanity_manager.decrease_sanity(10)

	if event.is_action_pressed("ui_cancel"):
		sanity_manager.increase_sanity(10)

func start_day():

	print("===== DAY START =====")

	profit_manager.reset_profit()
	sanity_manager.reset_sanity()

	event_runner.start(GameData.DAY1)

func _on_day_finished():

	print("========================")
	print("===== DAY 1 COMPLETE =====")
	print("========================")


func _on_customer_arrived():

	print("GameManager menerima: Customer sampai kasir")

	event_runner.next_event()


func _on_customer_exited():

	print("GameManager menerima: Customer keluar")

	event_runner.next_event()


func _on_dialog_finished():

	print("Dialogue selesai")

	event_runner.next_event()


func _on_typing_finished():

	print("Typing selesai")

	if customer_manager.current_customer != null:
		customer_manager.current_customer.receive_food()

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

				if customer_manager.current_customer != null:
					customer_manager.current_customer.start_waiting()

				order_requested.emit(event["recipe"])

				typing_manager.start_typing(event)


		"exit":

			print("Customer Exit")

			customer_manager.exit_customer()


		"spawn_customer":

			customer_manager.spawn_customer(event["name"])
