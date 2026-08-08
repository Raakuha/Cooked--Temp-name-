extends Node
class_name WorkstationRegistry

var workstations: Dictionary = {
#	isi Refrigerator, stove , dsb disini
}

func _ready() -> void:
	await get_tree().process_frame
	
	var found_workstation = get_tree().get_nodes_in_group("workstations")
	for station in found_workstation:
		register_workstation(station)
	print(workstations.keys())
	
func register_workstation(workstation: Workstation) -> void:
	workstations[workstation.command.to_upper()] = workstation
	
	
	

func get_workstation(command: String) -> Workstation:
	return workstations.get(command.to_upper())
