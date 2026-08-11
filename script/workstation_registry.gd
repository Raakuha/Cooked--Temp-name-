extends Node
class_name WorkstationRegistry

var workstations: Dictionary = {}


func _ready() -> void:
	var found_workstations = get_tree().get_nodes_in_group("workstations")

	for station in found_workstations:
		register_workstation(station)


func register_workstation(workstation: Workstation) -> void:
	workstations[workstation.command.to_upper()] = workstation


func get_workstation(command: String) -> Workstation:
	return workstations.get(command.to_upper())
