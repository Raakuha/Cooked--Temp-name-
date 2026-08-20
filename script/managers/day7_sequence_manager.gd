class_name Day7SequenceManager
extends Node

signal sequence_started
signal sequence_finished

@onready var dialogue_manager: DialogueManager = $"../DialogueManager"
@onready var camera_director: CameraDirector = $"../CameraDirector"
@onready var transition_layer: TransitionLayer = $"../../UI/TransitionLayer"
@onready var player: PlayerController = $"../../PlayerBaru"

@onready var basement_player_start: Marker3D = $"../../SpawnPoints/BasementPlayerStart"

@onready var mysterious_spawn: Marker3D = $"../../SpawnPoints/MysteriousSpawn"

@export var mysterious_scene: PackedScene

var active: bool = false
var mysterious_instance: Node3D = null


func play_day7_sequence() -> void:

	if active:
		return

	active = true

	print("========================")
	print("DAY 7 SEQUENCE")
	print("SEQUENCE START")
	print("========================")

	sequence_started.emit()

	spawn_mysterious_customer()

	await get_tree().create_timer(0.2).timeout

	await play_mysterious_dialogue()

	remove_mysterious_customer()

	# =========================================
	# CUSTOMER MENGHILANG
	# =========================================



	await play_glitch()




	# =========================================
	# MASUK KE FPP
	# =========================================

	print("========================")
	print("SWITCH TO FPP")
	print("========================")

	await transition_layer.fade_out(0.7)

	player.global_position = basement_player_start.global_position

	camera_director.switch_to_fpp()

	await transition_layer.fade_in(0.7)

	print("========================")
	print("DAY 7 SEQUENCE")
	print("FPP ACTIVE")
	print("========================")

	active = false

	sequence_finished.emit()

func spawn_mysterious_customer() -> void:

	if mysterious_scene == null:
		print("Mysterious Scene belum dipasang.")
		return

	if mysterious_instance != null:
		print("Mysterious customer sudah ada.")
		return

	print("========================")
	print("SPAWN MYSTERIOUS CUSTOMER")
	print("========================")

	mysterious_instance = mysterious_scene.instantiate()

	get_tree().current_scene.add_child(mysterious_instance)

	mysterious_instance.global_position = mysterious_spawn.global_position

	print(
		"Mysterious customer muncul di : ",
		mysterious_instance.global_position
	)


func remove_mysterious_customer() -> void:

	if mysterious_instance == null:
		return

	print("========================")
	print("MYSTERIOUS CUSTOMER DISAPPEARS")
	print("========================")

	mysterious_instance.queue_free()
	mysterious_instance = null


func play_glitch() -> void:

	print("========================")
	print("DAY 7 GLITCH")
	print("========================")

	for i in range(3):

		await transition_layer.fade_out(0.08)
		await transition_layer.fade_in(0.08)


func play_mysterious_dialogue() -> void:

	var dialogues := [

		{
			"mode": "fullscreen",
			"speaker": "???",
			"text": "....."
		},

		{
			"mode": "fullscreen",
			"speaker": "???",
			"text": "Kurasa sudah waktunya kau melihat isi dapurmu lagi."
		}
	]

	for dialog in dialogues:

		dialogue_manager.start_dialog(dialog)

		await dialogue_manager.dialogue_finished
