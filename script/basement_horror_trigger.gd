class_name BasementHorrorTrigger
extends Area3D

@export var camera_director: CameraDirector
@export var player: Player
@export var horror_sequence_manager: HorrorSequenceManager

var triggered: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)

	print("========================")
	print("BASEMENT HORROR TRIGGER READY")
	print("========================")


func _on_body_entered(body: Node3D) -> void:

	if triggered:
		return

	if body != player:
		return

	triggered = true

	print("========================")
	print("PLAYER ENTERED HORROR AREA")
	print("========================")

	trigger_horror()


func trigger_horror() -> void:

	print("BASEMENT HORROR TRIGGERED")

	if player != null:
		player.set_movement_enabled(false)
		player.set_mouse_look_enabled(false)

	if camera_director != null:
		camera_director.switch_to_horror()

	if horror_sequence_manager != null:
		horror_sequence_manager.play_basement_sequence()
