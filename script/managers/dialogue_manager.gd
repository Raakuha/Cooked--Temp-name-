extends Node

@export var bubble : CanvasLayer

var dialogues = []
var current = 0

var after_event = ""


func start_dialog(dialog_data):

	current = 0

	dialogues = dialog_data["dialogues"]

	after_event = dialog_data["after"]

	bubble.show_dialog(dialogues[current])


func next():

	current += 1

	if current >= dialogues.size():

		bubble.hide_dialog()

		return

	bubble.show_dialog(dialogues[current])
