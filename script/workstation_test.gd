extends Node3D

@onready var workstation_registry: WorkstationRegistry = $workstation_registry
@onready var player: Player = $Player
@onready var typing_manager: TypingManager = $TypingManager
@onready var typing_ui: Control = $TypingUI

var action_step: int = 0

enum TypingPhase{
	WORKSTATION,
	ACTION
}
var typing_phase : TypingPhase = TypingPhase.WORKSTATION
var current_workstation : Workstation 


func _ready() -> void:
	await get_tree().process_frame
	typing_manager.start_typing("REFRIGERATOR")

func _on_typing_manager_typing_completed(command: String) -> void:
	match typing_phase:
		TypingPhase.WORKSTATION:
			current_workstation = workstation_registry.get_workstation(command)
			if current_workstation != null:
				var target_position = current_workstation.get_navigation_position()
				player.move_to_target(target_position)
		TypingPhase.ACTION:
			if current_workstation != null:
				if action_step == 0:
					current_workstation.perform_action("OPEN")
					current_workstation.complete_action()
					action_step = 1
					typing_manager.call_deferred("start_typing", "AMBIL NASI")
				elif action_step == 1:
					current_workstation.perform_action("TAKE RICE")
					current_workstation.complete_action()
					action_step = 2
					current_workstation.finish_interaction()
			



func _on_player_arrived_at_target() -> void:
	if current_workstation != null:
		current_workstation.start_interaction()

		typing_phase = TypingPhase.ACTION
		action_step = 0
		typing_manager.start_typing("BUKA KULKAS")
