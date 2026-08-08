extends Node3D

@onready var workstation_registry: WorkstationRegistry = $workstation_registry
@onready var player: Player = $Player
var current_step: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	
	var target_workstation = workstation_registry.get_workstation("STOVE")

	if target_workstation != null:
		var target_position = target_workstation.get_navigation_position()
		player.move_to_target(target_position)
	


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


func _on_player_arrived_at_target() -> void:
	print("STEP: ", current_step)
	var target_refrigerator = workstation_registry.get_workstation("REFRIGERATOR")
	var target_microwave = workstation_registry.get_workstation("MICROWAVE")
	if current_step == 0:
		current_step = 1
		var position_refrigerator = target_refrigerator.get_navigation_position()
		player.move_to_target(position_refrigerator)
	elif current_step == 1:
		current_step = 2
		var position_microwave = target_microwave.get_navigation_position()
		player.move_to_target(position_microwave)
		
	
