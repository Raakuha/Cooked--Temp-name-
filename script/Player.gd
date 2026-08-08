extends CharacterBody3D

class_name Player
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
signal arrived_at_target
var is_moving: bool = false

const SPEED = 5.0
const ARRIVAL = 1.0

func move_to_target(new_target: Vector3) -> void:
	print("PLAYER: ", global_position)
	print("TARGET: ", new_target)

	navigation_agent_3d.target_position = new_target
	is_moving = true
	
	

func _ready() -> void:
	navigation_agent_3d.path_desired_distance = ARRIVAL
	navigation_agent_3d.target_desired_distance = ARRIVAL
	

func _physics_process(delta: float) -> void:
	if is_moving:
		if navigation_agent_3d.is_navigation_finished():
			is_moving = false
			velocity.x = 0
			velocity.z = 0
			arrived_at_target.emit() 
			print("Player sampe target")
			
			return
		var next_position = navigation_agent_3d.get_next_path_position()
		var arah_target : Vector3 = next_position - global_position	
		arah_target.y = 0
		arah_target = arah_target.normalized()
		velocity.x = SPEED * arah_target.x
		velocity.z = SPEED * arah_target.z
		
	move_and_slide()
		
			
		
#
