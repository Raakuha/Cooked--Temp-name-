class_name GameData
extends Node

static func get_day_events(day: int) -> Array:
	match day:
		1:
			return DAY1

		2:
			return DAY2

		3:
			return DAY3

		4:
			return DAY4

		5:
			return DAY5

		6:
			return DAY6

		7:
			return DAY7

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

]



const DAY2 = [

	{
		"type": "spawn_customer",
		"customer_id": "andrian"
	},

	{
		"type": "customer_opening"
	},

	{
		"type": "typing"
	},
]

const DAY3 = [

	{
		"type": "spawn_customer",
		"customer_id": "mika"
	},

	{
		"type": "customer_opening"
	},

	{
		"type": "typing"
	},

	{
		"type": "spawn_customer",
		"customer_id": "pete"
	},

	{
		"type": "customer_opening"
	},

	{
		"type": "typing"
	},

	{
		"type": "spawn_customer",
		"customer_id": "lane"
	},

	{
		"type": "customer_opening"
	},

	{
		"type": "typing"
	}
]

const DAY4 = [

	{
		"type": "spawn_customer",
		"customer_id": "harlan"
	},

	{
		"type": "customer_opening"
	},

	{
		"type": "typing"
	},

	{
		"type": "spawn_customer",
		"customer_id": "james"
	},

	{
		"type": "customer_opening"
	},

	{
		"type": "typing"
	}
]


const DAY5 = [

	{
		"type": "spawn_group",
		"group_id": "juan_abel_mark"
	},

	{
		"type": "spawn_customer",
		"customer_id": "roy"
	},

	{
		"type": "customer_opening"
	},

	{
		"type": "typing"
	}
]




const DAY6 = [

	{
		"type": "spawn_customer",
		"customer_id": "dion"
	},

	{
		"type": "customer_opening"
	},

	{
		"type": "typing"
	},

	{
		"type": "spawn_mika_day6"
	},

	{
		"type": "customer_opening"
	},

	{
		"type": "typing"
	}
]



const DAY7 = [

	{
		"type": "mysterious_customer"
	}
]
