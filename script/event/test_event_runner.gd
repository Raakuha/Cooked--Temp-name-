extends Node

@onready var runner : EventRunner = $EventRunner


func _ready():

	var events = [

		{
			"type":"dialog",
			"id":"opening"
		},

		{
			"type":"typing",
			"recipe":"burger"
		},

		{
			"type":"dialog",
			"id":"ending"
		},

		{
			"type":"exit"
		}

	]

	runner.start(events)


func _input(event):

	if event.is_action_pressed("ui_accept"):

		runner.next_event()
