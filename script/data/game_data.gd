class_name GameData
extends Node


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
		"recipe": "nasi_goreng"
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
