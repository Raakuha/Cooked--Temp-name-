extends Node3D

@onready var workstation_registry: WorkstationRegistry = $workstation_registry
@onready var player: Player = $Player
var current_step: int = 0
@onready var typing_manager: TypingManager = $TypingManager
@onready var typing_ui: Control = $TypingUI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	typing_manager.start_typing("MICROWAVE")






func _on_typing_manager_typing_completed(command: String) -> void:
	var target_workstation =  workstation_registry.get_workstation(command)
	if target_workstation != null:
		var target_position = target_workstation.get_navigation_position()
		player.move_to_target(target_position)
		
	
