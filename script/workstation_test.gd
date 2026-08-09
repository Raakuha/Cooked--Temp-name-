extends Node3D

@onready var workstation_registry: WorkstationRegistry = $workstation_registry
@onready var player: Player = $Player
@onready var typing_manager: TypingManager = $TypingManager
@onready var typing_ui: Control = $TypingUI

var current_workstation : Workstation 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	typing_manager.start_typing("MICROWAVE")






func _on_typing_manager_typing_completed(command: String) -> void:
	current_workstation =  workstation_registry.get_workstation(command)
	if current_workstation != null:
		var target_position = current_workstation.get_navigation_position()
		player.move_to_target(target_position)

		
		
	


func _on_player_arrived_at_target() -> void:
	if current_workstation != null:
		current_workstation.start_interaction()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if current_workstation != null:
			if current_workstation.is_interact:
				current_workstation.finish_interaction()
