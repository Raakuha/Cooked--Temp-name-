extends Node3D

@onready var player = $Player
@onready var target_marker_b: Marker3D = $TargetMarkerB
@onready var target_marker_a: Marker3D = $TargetMarkerA

var movement_step : int = 0

func _ready() -> void:
	pass




func _on_player_arrived_at_target() -> void:
	if movement_step == 1:
		player.move_to_target(target_marker_a.global_position)
		movement_step = 2
	elif movement_step == 2:
		print("Player berhasil gerak ke kulkas lur")
	
	


func _on_typing_prototype_typing_completed(command: String) -> void:
	if command == "REFRIGERATOR":
			player.move_to_target(target_marker_b.global_position)
			movement_step = 1
	
