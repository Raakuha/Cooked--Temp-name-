extends Node3D
class_name Workstation

@export var command : String = ""
@onready var navigation_target: Marker3D = $NavigationTarget
@onready var prompt_anchor: Marker3D = $PromptAnchor
@export var typing_ui: TypingUI
signal interaction_started
signal interaction_finished
signal action_completed(workstation, action_name)

var action_in_progress : bool = false
var current_action: String = ""
var is_interact : bool = false
var current_action_data: Dictionary = {}

@export var camera_controller : CameraController
@export var interaction_camera_anchor : Marker3D
@export var typing_manager: TypingManager
@export var animation_player: AnimationPlayer
@export var start_animations: Dictionary = {}
@export var complete_animations: Dictionary = {}


@export var stove_timing_ui: StoveTimingUI


@export var item_pick_manager: ItemPickManager


var last_timing_results: Array = []


signal action_started(action_name : String)
signal action_finished(action_name : String)
signal timing_result(workstation: Workstation, action_name: String, results: Array)


signal wrong_item_picked(
	workstation: Workstation,
	picked_item_id: String,
	required_item_id: String
)


signal item_picked(workstation: Workstation, item_id: String)


var last_picked_item_id: String = ""
var current_picked_item_id: String = ""
func get_navigation_position() -> Vector3 :
	return navigation_target.global_position
	
func get_prompt_position() -> Vector3:
	return prompt_anchor.global_position
	
func _enter_tree() -> void:
	add_to_group("workstations")

func _try_play_animation(clip_name: String) -> void:
	if clip_name == "" or animation_player == null:
		return

	if not animation_player.has_animation(clip_name):
		return

	animation_player.play(clip_name)

func perform_action( action_name: String, interaction_data: Dictionary = {}) -> void:
	action_in_progress = true
	current_action = action_name
	current_action_data = interaction_data

	action_started.emit(action_name)
	_try_play_animation(start_animations.get(action_name, ""))
	
	match action_name:
		"TAKE":
			run_take_action()

		"ADD":
			run_add_action()

		"OPEN":
			run_open_action()

		"CLOSE":
			run_close_action()

		"CUT":
			run_cut_action()

		"MIX":
			run_mix_action()

		"COOK":
			run_cook_action()

		"FRY":
			run_fry_action()

		"PLATE":
			run_plate_action()

		"SERVE":
			run_serve_action()

		_:
			push_warning(
				"Action tidak dikenali: " + action_name
			)
			complete_action()
func run_take_action() -> void:
	var required_item_id: String = current_action_data.get(
		"item_id",
		""
	)

	var required_item_ids: Array = current_action_data.get(
		"item_ids",
		[]
	)

	if required_item_ids.is_empty() and required_item_id != "":
		required_item_ids = [required_item_id]

	# RESET TOTAL untuk action TAKE baru
	last_picked_item_id = ""
	current_picked_item_id = ""

	if required_item_ids.is_empty() or item_pick_manager == null:
		finish_action_after_delay(0.3)
		return

	var candidates: Array = WorkstationInventory.get_items(command)

	if candidates.is_empty():
		push_warning(
			"WorkstationInventory kosong untuk: "
			+ command
			+ " -- fallback ke delay biasa."
		)

		finish_action_after_delay(0.3)
		return

	var picked_ids_this_visit: Array = []

	while true:


		var picked: Dictionary = await item_pick_manager.run_pick(
			candidates
		)

		if picked.get("cancelled", false):
			print(
				"[Workstation] TAKE dibatalkan karena restart."
			)

			action_in_progress = false
			current_action = ""
			current_action_data = {}
			return

		if picked.get("exit", false):
			break

	
		if not required_item_ids.has(picked["item_id"]):

			wrong_item_picked.emit(
				self,
				picked["item_id"],
				required_item_id
			)


			var return_cancelled: bool = (
				await item_pick_manager.run_return(
					picked["label"]
				)
			)

			if return_cancelled:
				print(
					"[Workstation] RETURN dibatalkan karena restart."
				)

				action_in_progress = false
				current_action = ""
				current_action_data = {}
				return

			continue


		current_picked_item_id = picked["item_id"]
		last_picked_item_id = current_picked_item_id

		picked_ids_this_visit.append(
			picked["item_id"]
		)

		item_picked.emit(
			self,
			picked["item_id"]
		)

		var remaining: Array = required_item_ids.filter(
			func(id):
				return not picked_ids_this_visit.has(id)
		)

		if remaining.is_empty():
			# Semua item yang dibutuhkan sudah diambil.
			break


		var exit_cancelled: bool = (
			await item_pick_manager.wait_for_exit(
				picked["label"]
			)
		)

		if exit_cancelled:
			print(
				"[Workstation] EXIT WAIT dibatalkan karena restart."
			)

			action_in_progress = false
			current_action = ""
			current_action_data = {}
			return

	complete_action()
func run_add_action() -> void:
	

	finish_action_after_delay(0.3)


func run_open_action() -> void:


	finish_action_after_delay(0.3)


func run_close_action() -> void:


	finish_action_after_delay(0.3)


func run_cut_action() -> void:
	var prompts: Array = current_action_data.get(
		"prompts",
		["CUT"]
	)

	if camera_controller == null:
		push_warning("CameraController belum dipasang.")
		complete_action()
		return

	if interaction_camera_anchor == null:
		push_warning("InteractionCameraAnchor belum dipasang.")
		complete_action()
		return

	if typing_manager == null:
		push_warning("TypingManager belum dipasang.")
		complete_action()
		return

	camera_controller.enter_interaction(
		interaction_camera_anchor
	)

	await camera_controller.transition_finished

	typing_ui.use_screen_mode()

	for prompt in prompts:
		typing_manager.call_deferred(
			"start_typing",
			String(prompt)
		)

		var result = await typing_manager.typing_completed

		if result == "CANCELED":
			print(
				"[Workstation] CUT dibatalkan karena restart."
			)

			camera_controller.exit_interaction()
			typing_ui.use_world_mode()

			await camera_controller.transition_finished

			action_in_progress = false
			current_action = ""
			current_action_data = {}

			return
	camera_controller.exit_interaction()

	typing_ui.use_world_mode()

	await camera_controller.transition_finished

	complete_action()

func run_mix_action() -> void:


	var prompts: Array = current_action_data.get(
		"prompts",
		["MIX"]
	)

	print("[CookingAction] Interaction prompts: ", prompts)

	if camera_controller == null:
		push_warning("CameraController belum dipasang.")
		complete_action()
		return

	if interaction_camera_anchor == null:
		push_warning("InteractionCameraAnchor belum dipasang.")
		complete_action()
		return

	if typing_manager == null:
		push_warning("TypingManager belum dipasang.")
		complete_action()
		return

	camera_controller.enter_interaction(
		interaction_camera_anchor
	)

	await camera_controller.transition_finished
	typing_ui.use_screen_mode()



	for prompt in prompts:
		typing_manager.call_deferred(
			"start_typing",
			String(prompt)
		)

		var result = await typing_manager.typing_completed

		if result == "CANCELED":
			print(
				"[Workstation] MIX dibatalkan karena restart."
			)

			camera_controller.exit_interaction()
			typing_ui.use_world_mode()

			await camera_controller.transition_finished

			action_in_progress = false
			current_action = ""
			current_action_data = {}

			return

	camera_controller.exit_interaction()
	typing_ui.use_world_mode()
	await camera_controller.transition_finished

	complete_action()

func run_cook_action() -> void:
	await run_stove_timing_sequence()


func run_fry_action() -> void:
	await run_stove_timing_sequence()


## R-P3-09 --- Dipakai oleh COOK dan FRY. Menjalankan 1 ronde timing per
## item di interaction.prompts (kalau tidak ada, default 1 ronde "COOK"),
## persis pola perulangan yang sama seperti run_cut_action/run_mix_action
## tapi memakai StoveTimingUI, bukan TypingManager.
func run_stove_timing_sequence() -> void:
	if stove_timing_ui == null:
		push_warning(
			"StoveTimingUI belum dipasang di " + command
			+ " -- fallback ke delay biasa (belum ada skill-check)."
		)
		finish_action_after_delay(1.0)
		return

	var prompts: Array = current_action_data.get(
		"prompts",
		["COOK"]
	)

	if camera_controller != null and interaction_camera_anchor != null:
		camera_controller.enter_interaction(interaction_camera_anchor)
		await camera_controller.transition_finished

	var results: Array = []

	for prompt in prompts:
		var result: String = await stove_timing_ui.run_timing(String(prompt))
		
		if result == "CANCELED":
			print(
				"[Workstation] ",
				command,
				" timing dibatalkan karena restart."
			)

			if camera_controller != null and interaction_camera_anchor != null:
				camera_controller.exit_interaction()
				await camera_controller.transition_finished

			action_in_progress = false
			current_action = ""
			current_action_data = {}

			return
		results.append(result)

		print(
			"[Workstation] ", command,
			" timing '", prompt, "' -> ", result
		)

	if camera_controller != null and interaction_camera_anchor != null:
		camera_controller.exit_interaction()
		await camera_controller.transition_finished

	last_timing_results = results

	timing_result.emit(self, current_action, results)

	complete_action()


func run_plate_action() -> void:


	finish_action_after_delay(0.5)


func run_serve_action() -> void:


	finish_action_after_delay(0.5)

func complete_action() -> void:
	if not action_in_progress:
		return

	var finished_action := current_action

	action_in_progress = false
	current_action = ""
	current_action_data = {}

	print(
		"[Workstation] ",
		command,
		" selesai action: ",
		finished_action,
		" | item = ",
		current_picked_item_id
	)
	_try_play_animation(complete_animations.get(finished_action, ""))
	
	action_finished.emit(finished_action)

	action_completed.emit(
		self,
		finished_action
	)
func start_interaction() -> void:
	if is_interact:
		return
	is_interact = true
	print("Interaction " + command + " Dimulai")
	interaction_started.emit()

func finish_interaction() -> void:
	if not is_interact:
		return

	if current_action != "":
		return

	is_interact = false
	print("Interaction " + command + " Selesai") 
	interaction_finished.emit()

func finish_action_after_delay(duration: float) -> void:
	var timer := get_tree().create_timer(duration)
	timer.timeout.connect(complete_action)
	
func cancel_current_action() -> void:
	if not action_in_progress:
		return

	print(
		"[Workstation] REQUEST CANCEL ACTION: ",
		command,
		" / ",
		current_action
	)

	if item_pick_manager != null:
		item_pick_manager.cancel()

	if stove_timing_ui != null:
		stove_timing_ui.cancel()

	if typing_manager != null:
		typing_manager.cancel()

	if typing_ui != null:
		typing_ui.cancel()
