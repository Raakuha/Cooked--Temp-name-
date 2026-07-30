extends CharacterBody3D


const SPEED = 5.0
const ARRIVAL = 0.2

signal arrived_at_target
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

var target_pos : Vector3 = Vector3.ZERO
var is_moving : bool = false
#test
func _ready() -> void:
	navigation_agent_3d.target_desired_distance = ARRIVAL
	
func move_to_target(new_target : Vector3) -> void:
	#baris pertama melakukan perubahan is_moving jadi true
	is_moving = true
	
	target_pos = new_target
	navigation_agent_3d.target_position = new_target

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_moving:
		var next_path_position : Vector3 = navigation_agent_3d.get_next_path_position()
		var to_next_position : Vector3 = next_path_position - global_position
		to_next_position.y = 0.0
		var direction : Vector3 = to_next_position.normalized()
		velocity.x = SPEED * direction.x
		velocity.z = SPEED * direction.z
		#var to_target: Vector3 = target_pos - global_position
		#to_target.y = 0.0
		#
		#var dist_to_target :float = to_target.length()
		#if dist_to_target <= ARRIVAL:
			#is_moving = false
			##velocity di 0 kan?
			#velocity.x = 0
			#velocity.z = 0
			#arrived_at_target.emit()
			#
		#else :
			#is_moving = true
			#var direction = to_target.normalized()
			#velocity.x = direction.x * SPEED
			#velocity.z = direction.z * SPEED
			#
		pass
		
	move_and_slide()
