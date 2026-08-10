class_name TypingManager
extends Node


signal typing_finished


var current_typing = {}


func start_typing(data):

	current_typing = data

	print("========================")
	print("TYPING DIMULAI")
	print("Recipe :", data["recipe"])
	print("========================")


func finish_typing():

	if current_typing.is_empty():
		return

	print("========================")
	print("TYPING SELESAI")
	print("========================")

	# PENTING:
	# kosongkan status typing sebelum signal dikirim
	current_typing = {}

	typing_finished.emit()


func _unhandled_input(event):

	if event.is_action_pressed("ui_accept"):

		if current_typing.is_empty():
			return

		finish_typing()
