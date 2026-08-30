class_name TutorialSequenceManager
extends Node

signal tutorial_started
signal tutorial_finished
signal tutorial_order_finished

@onready var dialogue_manager: DialogueManager = $"../DialogueManager"
@onready var transition_layer: TransitionLayer = $"../../UI/TransitionLayer"
@onready var camera_director: CameraDirector = $"../CameraDirector"
@onready var music_manager: MusicManager =$"../Music_Manager"
@onready var tutorial_police: Node3D = $"../../World/TutorialPolice"
@onready var tutorial_police_point: Marker3D = $"../../SpawnPoints/TutorialPolicePoint"
@onready var tutorial_police_dialogue_marker: Marker3D = (
	$"../../World/TutorialPolice/DialogueMarker"
)

@onready var tutorial_menu: CanvasLayer = $"../../UI/TutorialMenu"

@onready var game_manager: GameManager = $"../GameManager"
@export var police_profile: PoliceProfile

@onready var cooking_sequence_manager: CookingSequenceManager = $"../CookingSequenceManager"

var active: bool = false
var tutorial_order_index: int = -1

var police_animation_player: AnimationPlayer = null


func _ready() -> void:

	cooking_sequence_manager.recipe_completed.connect(
		_on_recipe_completed
	)

	if tutorial_police != null:

		police_animation_player = tutorial_police.find_child(
			"AnimationPlayer",
			true,
			false
		) as AnimationPlayer

		if police_animation_player != null:

			print(
				"Tutorial Police AnimationPlayer ditemukan."
			)

		else:

			print(
				"Tutorial Police AnimationPlayer tidak ditemukan."
			)


func play_police_idle() -> void:

	if police_animation_player == null:
		print("AnimationPlayer polisi tidak tersedia.")
		return

	if not police_animation_player.has_animation("idle"):

		print(
			"Animasi idle polisi tidak ditemukan."
		)

		return

	print("TUTORIAL POLICE -> IDLE")

	police_animation_player.play("idle")


func _on_recipe_completed(result: CookingResult) -> void:

	if not active:
		return

	if police_profile == null:
		return

	if result == null:
		return

	print("========================")
	print("TUTORIAL RECIPE COMPLETED")
	print("Recipe :", result.recipe_id)
	print("========================")


	# MAIN RECIPE
	if tutorial_order_index == -1:

		if result.recipe_id != police_profile.recipe_id:
			return

		print("MAIN RECIPE SELESAI")

		await start_next_additional_order()

		return


	# ADDITIONAL ORDER
	var expected_order := (
		police_profile.additional_orders[tutorial_order_index]
	)

	if result.recipe_id != expected_order:
		return

	print(
		"ADDITIONAL ORDER SELESAI : ",
		result.recipe_id
	)

	await start_next_additional_order()

func start_tutorial_order() -> void:

	if police_profile == null:
		return

	tutorial_order_index = -1

	hide_tutorial_menu()

	print("========================")
	print("TUTORIAL ORDER START")
	print("MAIN RECIPE :", police_profile.recipe_id)
	print("ADDITIONAL ORDERS :", police_profile.additional_orders)
	print("========================")

	start_main_recipe()


func start_main_recipe() -> void:

	print("========================")
	print("START MAIN RECIPE")
	print("Recipe :", police_profile.recipe_id)
	print("========================")

	tutorial_order_index = -1

	cooking_sequence_manager.start_recipe(
		police_profile.recipe_id
	)

func start_next_additional_order() -> void:

	if police_profile.additional_orders.is_empty():

		print("========================")
		print("NO ADDITIONAL ORDERS")
		print("========================")

		await finish_tutorial_order()
		return


	var next_index := tutorial_order_index + 1

	if next_index >= police_profile.additional_orders.size():

		print("========================")
		print("ALL ADDITIONAL ORDERS FINISHED")
		print("========================")

		await finish_tutorial_order()
		return


	tutorial_order_index = next_index

	var order_id := police_profile.additional_orders[tutorial_order_index]

	print("========================")
	print("ADDITIONAL ORDER START")
	print("Order :", order_id)
	print("========================")

	cooking_sequence_manager.start_recipe(order_id)

func finish_tutorial_order() -> void:

	print("========================")
	print("TUTORIAL ORDER FINISHED")
	print("========================")

	if police_profile == null:
		return

	for dialogue in police_profile.closing_dialogue:

		dialogue_manager.start_dialog(dialogue)

		await dialogue_manager.dialogue_finished

	await police_leave_restaurant()

func play_tutorial() -> void:

	if active:
		return

	active = true
	if music_manager != null:
		music_manager.play_tutorial_music()
	print("========================")
	print("RESTAURANT TUTORIAL")
	print("TUTORIAL START")
	print("========================")

	tutorial_started.emit()

	await play_restaurant_intro()

	print("========================")
	print("RESTAURANT TUTORIAL")
	print("TUTORIAL SELESAI")
	print("========================")




func show_tutorial_menu() -> void:

	if tutorial_menu == null:
		print("TutorialMenu tidak ditemukan.")
		return

	tutorial_menu.show()

	print("========================")
	print("TUTORIAL MENU SHOW")
	print("========================")


func hide_tutorial_menu() -> void:

	if tutorial_menu == null:
		return

	tutorial_menu.hide()

func enter_restaurant() -> void:

	print("========================")
	print("ENTER RESTAURANT")
	print("========================")

	await transition_layer.fade_out(0.7)

	camera_director.switch_to_gameplay()

	tutorial_police.global_position = (
		tutorial_police_point.global_position
	)

	print("Tutorial Police Position : ", tutorial_police.global_position)
	print("Tutorial Police Point    : ", tutorial_police_point.global_position)

	tutorial_police.show()
	
	play_police_idle()

	print("Tutorial Police Visible  : ", tutorial_police.visible)

	await transition_layer.fade_in(0.7)

	print("RESTAURANT TUTORIAL SCENE ACTIVE")


func play_restaurant_intro() -> void:

	await enter_restaurant()

	if police_profile == null:
		print("Police profile belum dipasang.")
		return

	print("========================")
	print("POLICE RESTAURANT DIALOGUE")
	print(
		"Jumlah dialogue : ",
		police_profile.restaurant_dialogue.size()
	)
	print("========================")


	for i in range(police_profile.restaurant_dialogue.size()):

		var dialogue = police_profile.restaurant_dialogue[i]

		dialogue_manager.start_dialog(
			dialogue,
			tutorial_police_dialogue_marker
		)

		await dialogue_manager.dialogue_finished

		if i == 2:
			show_tutorial_menu()


	start_tutorial_order()

	await tutorial_order_finished







func police_leave_restaurant() -> void:

	print("========================")
	print("TUTORIAL POLICE LEAVING")
	print("========================")

	await transition_layer.fade_out(0.7)

	tutorial_police.hide()

	await transition_layer.fade_in(0.7)

	print("POLICE LEFT RESTAURANT")
	
	if music_manager != null:
		music_manager.stop_tutorial_music()
		
	tutorial_order_finished.emit()

	active = false

	tutorial_finished.emit()
