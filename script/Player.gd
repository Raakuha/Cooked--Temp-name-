extends CharacterBody3D

class_name Player
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
signal arrived_at_target
var is_moving: bool = false

const SPEED = 5.0
const ARRIVAL = 0.2

func move_to_target(new_target: Vector3) -> void:
	navigation_agent_3d.target_position = new_target
	is_moving = true
	
	

func _ready() -> void:
	navigation_agent_3d.target_desired_distance = ARRIVAL
	

func _physics_process(delta: float) -> void:
	if is_moving:
		if navigation_agent_3d.is_navigation_finished():
			is_moving = false
			velocity.x = 0
			velocity.z = 0
			arrived_at_target.emit() 
			
			return
		var next_position = navigation_agent_3d.get_next_path_position()
		var arah_target : Vector3 = next_position - global_position	
		arah_target.y = 0
		arah_target = arah_target.normalized()
		velocity.x = SPEED * arah_target.x
		velocity.z = SPEED * arah_target.z
		
	move_and_slide()
		
			
		
#

#

#
#var target_pos : Vector3 = Vector3.ZERO
#var is_moving : bool = false
#
#func move_to_target(new_target : Vector3) -> void:
	##baris pertama melakukan perubahan is_moving jadi true
	#is_moving = true
	#
	#target_pos = new_target
#
#func _physics_process(delta: float) -> void:
	#if not is_on_floor():
		#velocity += get_gravity() * delta
	#
	#if is_moving:
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
		#
	#move_and_slide()
