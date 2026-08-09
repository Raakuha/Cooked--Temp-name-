extends Node3D
class_name Workstation
@export var command : String = ""
@onready var navigation_target: Marker3D = $NavigationTarget
var is_interact : bool = false

signal interaction_started
signal interaction_finished

var current_action: String = ""

signal action_started(action_name : String)
signal action_finished(action_name : String)
func get_navigation_position() -> Vector3 :
	return navigation_target.global_position
func _ready() -> void:
	add_to_group("workstations")
	

func perform_action(action_name : String) -> void:
	if current_action != "":
		return
	if not is_interact:
		return
	
	current_action = action_name
	action_started.emit(action_name)
	print("Action " + action_name+ " sedang dijalankan")

func complete_action () -> void:
	if current_action == "":
		return
	if not is_interact:
		return
	var finished_action = current_action
	current_action = ""
	print("Action " + finished_action + " sudah selesai")
	action_finished.emit(finished_action)
	

func start_interaction() -> void:
	if is_interact:
		return
	is_interact = true
	print("Interaction " + command + " Dimulai")
	interaction_started.emit()

func finish_interaction() -> void:
	
	if not is_interact:
		return	
	is_interact = false
	print("Interaction " + command + " Selesai") 
	interaction_finished.emit()
