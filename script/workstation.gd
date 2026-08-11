extends Node3D
class_name Workstation
@export var command : String = ""
@onready var navigation_target: Marker3D = $NavigationTarget
var is_interact : bool = false
@onready var prompt_anchor: Marker3D = $PromptAnchor

signal interaction_started
signal interaction_finished
signal action_completed(workstation, action_name)

var action_in_progress : bool = false
var current_action: String = ""

@export var camera_controller : CameraController
@export var interaction_camera_anchor : Marker3D



signal action_started(action_name : String)
signal action_finished(action_name : String)
func get_navigation_position() -> Vector3 :
	return navigation_target.global_position
	
func get_prompt_position() -> Vector3:
	return prompt_anchor.global_position
	
func _enter_tree() -> void:
	add_to_group("workstations")

func perform_action(action_name: String) -> void:
	if action_in_progress:
		push_warning("Masih ada action yang sedang berjalan.")
		return

	action_in_progress = true
	current_action = action_name

	print(
		"[Workstation] ",
		command,
		" mulai action: ",
		action_name
	)

	action_started.emit(action_name)

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
	print("[CookingAction] TAKE")

	finish_action_after_delay(0.3)


func run_add_action() -> void:
	print("[CookingAction] ADD")

	finish_action_after_delay(0.3)


func run_open_action() -> void:
	print("[CookingAction] OPEN")

	finish_action_after_delay(0.3)


func run_close_action() -> void:
	print("[CookingAction] CLOSE")

	finish_action_after_delay(0.3)


func run_cut_action() -> void:
	print("[CookingAction] CUT")

	# Temporary.
	# Nanti diganti Cutting Board FPP interaction.
	finish_action_after_delay(1.0)


func run_mix_action() -> void:
	print("[CookingAction] MIX")

	# Temporary.
	# Nanti diganti Wok FPP interaction.
	finish_action_after_delay(1.0)


func run_cook_action() -> void:
	print("[CookingAction] COOK")

	finish_action_after_delay(1.0)


func run_fry_action() -> void:
	print("[CookingAction] FRY")

	finish_action_after_delay(1.0)


func run_plate_action() -> void:
	print("[CookingAction] PLATE")

	finish_action_after_delay(0.5)


func run_serve_action() -> void:
	print("[CookingAction] SERVE")

	finish_action_after_delay(0.5)

func complete_action() -> void:
	if not action_in_progress:
		return

	var finished_action := current_action

	action_in_progress = false
	current_action = ""

	print(
		"[Workstation] ",
		command,
		" selesai action: ",
		finished_action
	)

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
