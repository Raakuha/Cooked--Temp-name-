extends Node3D

@onready var player = $Player
@onready var target_marker_b: Marker3D = $TargetMarkerB


func _ready() -> void:
	await get_tree().physics_frame
	player.move_to_target(target_marker_b.global_position)
	


func _on_player_arrived_at_target() -> void:
	print("Player sudah sampai")
	
