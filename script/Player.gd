extends CharacterBody3D


const SPEED = 5.0
const ARRIVAL = 0.2

signal arrived_at_target

var target_pos : Vector3 = Vector3.ZERO
var is_moving : bool = false

func move_to_target(new_target : Vector3) -> void:
	#baris pertama melakukan perubahan is_moving jadi true
	is_moving = true
	
	target_pos = new_target

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_moving:
		var to_target: Vector3 = target_pos - global_position
		to_target.y = 0.0
		
		var dist_to_target :float = to_target.length()
		if dist_to_target <= ARRIVAL:
			is_moving = false
			#velocity di 0 kan?
			velocity.x = 0
			velocity.z = 0
			arrived_at_target.emit()
			
		else :
			is_moving = true
			var direction = to_target.normalized()
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			
		
	move_and_slide()
