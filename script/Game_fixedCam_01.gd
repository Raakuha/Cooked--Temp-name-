extends Node3D

@onready var player = $Player
@onready var target_marker_b: Marker3D = $TargetMarkerB
@onready var target_marker_a: Marker3D = $TargetMarkerA


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.move_to_target(target_marker_b.global_position)
	player.arrived_at_target.connect(_on_player_arrived_at_target)
	
	pass

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass



func _on_player_arrived_at_target() -> void:
	player.move_to_target(target_marker_a.global_position)
	
	print("Player udah sampai nih !")
