extends Node3D
class_name Workstation
@export var command : String = ""
@onready var navigation_target: Marker3D = $NavigationTarget


func get_navigation_position() -> Vector3 :
	return navigation_target.global_position
## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("workstations")
	pass # Replace with function body.

#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
