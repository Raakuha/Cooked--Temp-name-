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

	# ========================================
	# CUSTOMER 1
	# ========================================

	{
		"type": "spawn_customer",
		"name": "Pak Budi"
	},

	{
		"type": "dialog",
		"mode": "bubble",
		"speaker": "customer",
		"text": "Permisi, masih buka?"
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
		"text": "Saya mau nasi goreng."
	},

	{
		"type": "typing",
		"recipe": "nasgor_goreng"
	},

	{
		"type": "dialog",
		"mode": "bubble",
		"speaker": "customer",
		"text": "Terima kasih, makanannya enak."
	},

	{
		"type": "exit"
	},


	# ========================================
	# CUSTOMER 2
	# ========================================

	{
		"type": "spawn_customer",
		"name": "Bu Siti"
	},

	{
		"type": "dialog",
		"mode": "bubble",
		"speaker": "customer",
		"text": "Permisi, masih buka?"
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
		"text": "Saya mau mie goreng."
	},

	{
		"type": "typing",
		"recipe": "mie_goreng"
	},

	{
		"type": "dialog",
		"mode": "bubble",
		"speaker": "customer",
		"text": "Terima kasih."
	},

	{
		"type": "exit"
	},


	# ========================================
	# CUSTOMER 3
	# ========================================

	{
		"type": "spawn_customer",
		"name": "Pak Joko"
	},

	{
		"type": "dialog",
		"mode": "bubble",
		"speaker": "customer",
		"text": "Permisi, masih buka?"
	},

	{
		"type": "dialog",
		"mode": "bubble",
		"speaker": "mc",
		"text": "Masih."
	},

	{
		"type": "typing",
		"recipe": "ayam_goreng"
	},

	{
		"type": "dialog",
		"mode": "bubble",
		"speaker": "customer",
		"text": "Terima kasih."
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
