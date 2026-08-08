class_name EventRunner
extends Node


signal event_started(event)
signal finished


var events = []
var current = 0


func start(event_list):

	events = event_list
	current = 0

	run_current()


func next_event():

	current += 1

	run_current()


func run_current():

	if current >= events.size():

		finished.emit()

		return

	event_started.emit(events[current])
