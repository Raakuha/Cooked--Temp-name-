class_name Customer
extends Node3D

signal arrived
signal exited

enum State {
	SPAWNING,
	MOVING_TO_CASHIER,
	ORDERING,
	WAITING,
	RECEIVING,
	LEAVING,
	DONE
}

var customer_name : String = ""
var state : State = State.SPAWNING


func set_state(new_state : State):
	state = new_state

	print(
		customer_name,
		" STATE → ",
		State.keys()[state]
	)


func walk_to_cashier(target_position : Vector3):

	set_state(State.MOVING_TO_CASHIER)

	print(customer_name + " berjalan ke kasir")

	var tween = create_tween()

	tween.tween_property(
		self,
		"global_position",
		target_position,
		1.5
	)

	await tween.finished

	print(customer_name + " sudah sampai di kasir")

	set_state(State.ORDERING)

	arrived.emit()


func start_waiting():

	set_state(State.WAITING)

	print(customer_name + " sedang menunggu makanan")


func receive_food():

	set_state(State.RECEIVING)

	print(customer_name + " menerima makanan")


func walk_out(target_position : Vector3):

	set_state(State.LEAVING)

	print(customer_name + " keluar restoran")

	var tween = create_tween()

	tween.tween_property(
		self,
		"global_position",
		target_position,
		1.5
	)

	await tween.finished

	print(customer_name + " sudah keluar")

	set_state(State.DONE)

	exited.emit()

	queue_free()
