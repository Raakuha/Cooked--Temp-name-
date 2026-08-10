class_name RecipeStepExecutor
extends Node

signal step_completed

@export var player: Player
@export var typing_manager: TypingManager
@export var workstation_registry: WorkstationRegistry
@export var typing_ui: TypingUI

var current_step: Dictionary = {}

var current_workstation: Workstation = null
var pending_workstation: Workstation = null


func _ready() -> void:
	typing_manager.typing_completed.connect(_on_typing_completed)
	player.arrived_at_target.connect(_on_player_arrived)


func execute_step(step: Dictionary) -> void:
	current_step = step

	var workstation_name: String = step["workstation"]
	var workstation: Workstation = workstation_registry.get_workstation(workstation_name)

	if workstation == null:
		push_error("Workstation tidak ditemukan: " + workstation_name)
		return

	typing_ui.set_world_target(
		workstation.get_prompt_position()
	)

	typing_manager.call_deferred(
		"start_typing",
		String(step["prompt"])
	)


func _on_typing_completed(_command: String) -> void:
	if current_step.is_empty():
		return

	match current_step["type"]:
		RecipeData.StepType.MOVE:
			start_move_step()

		RecipeData.StepType.ACTION:
			run_action_step()


func start_move_step() -> void:
	var workstation_name: String = current_step["workstation"]

	var target_workstation: Workstation = (
		workstation_registry.get_workstation(workstation_name)
	)

	if target_workstation == null:
		push_error("Workstation tidak ditemukan: " + workstation_name)
		return

	if current_workstation != null:
		current_workstation.finish_interaction()
		current_workstation = null

	pending_workstation = target_workstation

	player.move_to_target(
		target_workstation.get_navigation_position()
	)


func _on_player_arrived() -> void:
	if pending_workstation == null:
		return

	current_workstation = pending_workstation
	pending_workstation = null

	current_workstation.start_interaction()

	step_completed.emit()


func run_action_step() -> void:
	if current_workstation == null:
		push_error("Tidak ada workstation aktif.")
		return

	var required_workstation: String = current_step["workstation"]

	if current_workstation.command.to_upper() != required_workstation.to_upper():
		push_error(
			"Workstation salah. Dibutuhkan: " + required_workstation
		)
		return

	var action_value = current_step["action"]
	var action_name = RecipeData.ActionType.find_key(action_value)

	if action_name == null:
		push_error("Action tidak ditemukan.")
		return

	current_workstation.perform_action(String(action_name))

	# Untuk sementara action langsung dianggap selesai.
	# Nanti Cooking Action bisa menentukan kapan benar-benar selesai.
	current_workstation.complete_action()

	step_completed.emit()
