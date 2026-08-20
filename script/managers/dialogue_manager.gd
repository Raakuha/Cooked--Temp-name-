class_name DialogueManager
extends Node


signal dialogue_finished


@onready var bubble : DialogueBubble = $"../../UI/DialogueBubble"


var current_dialog = {}


func _ready():

	print("DialogueBubble:", bubble)


func start_dialog(dialog, target: Node3D = null):

	current_dialog = dialog

	bubble.set_target(target)

	bubble.show_dialog(dialog)


func finish_dialog():

	if not bubble.is_open():

		return


	bubble.hide_dialog()

	dialogue_finished.emit()


func _unhandled_input(event):

	if event.is_action_pressed("ui_accept"):

		if bubble.is_open():

			finish_dialog()
