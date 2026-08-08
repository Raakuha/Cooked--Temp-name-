class_name GameManager
extends Node


@onready var event_runner : EventRunner = $"../EventRunner"
@onready var dialogue_manager : DialogueManager = $"../DialogueManager"
@onready var customer_manager : CustomerManager = $"../CustomerManager"
@onready var typing_manager : TypingManager = $"../TypingManager"

@onready var player : Node3D = $"../../PlayerBaru"


func _ready():

	event_runner.event_started.connect(_on_event_started)

	dialogue_manager.dialogue_finished.connect(_on_dialog_finished)

	typing_manager.typing_finished.connect(_on_typing_finished)

	customer_manager.customer_arrived.connect(_on_customer_arrived)

	call_deferred("start_day")


func start_day():

	print("===== DAY START =====")

	customer_manager.spawn_customer()


func _on_customer_arrived():

	print("GameManager menerima: Customer sampai kasir")

	event_runner.start(GameData.DAY1)


func _on_dialog_finished():

	print("Dialogue selesai")

	event_runner.next_event()


func _on_typing_finished():

	print("Typing selesai")

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

			typing_manager.start_typing(event)


		"exit":

			print("Customer Exit")
