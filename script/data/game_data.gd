class_name GameData
extends Node

static func get_day_events(day: int) -> Array:
	match day:
		1:
			return DAY1

		2:
			return DAY2

		#3:
			#return DAY3
#
		#4:
			#return DAY4
#
		#5:
			#return DAY5
#
		#6:
			#return DAY6
#
		#7:
			#return DAY7

		_:
			return []

const DAY1 = [

	{
		"type": "spawn_customer",
		"customer_id": "ulbar"
	},

	{
		"type": "customer_opening"
	},

	{
		"type": "typing"
	},

	{
		"type": "spawn_customer",
		"customer_id": "nanda"
	},

	{
		"type": "customer_opening"
	},

	{
		"type": "typing"
	},

	{
		"type": "exit"
	}
]



const DAY2 = [

	{
		"type": "spawn_customer",
		"name": "Pak Test"
	},

	{
		"type": "dialog",
		"mode": "bubble",
		"speaker": "customer",
		"text": "Permisi."
	},

	{
		"type": "dialog",
		"mode": "bubble",
		"speaker": "mc",
		"text": "Masih."
	},

	{
		"type": "dialog",
		"mode": "bubble",
		"speaker": "customer",
		"text": "Saya mau makan."
	},

	{
		"type": "typing",
		"recipe": "nasi_goreng"
	},

	{
		"type": "exit"
	}
]
