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

	print("TYPING SELESAI")

	typing_finished.emit()
