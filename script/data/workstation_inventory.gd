extends RefCounted
class_name WorkstationInventory

const ITEMS: Dictionary = {
	"REFRIGERATOR": [
		{"item_id": "daging_cincang", "label": "DAGING CINCANG"},
		{"item_id": "daging_wagyu", "label": "DAGING WAGYU"},
		{"item_id": "daging", "label": "DAGING"},
		{"item_id": "telur", "label": "TELUR"},
		{"item_id": "butter", "label": "BUTTER"},
		{"item_id": "adonan", "label": "ADONAN"},
		{"item_id": "patty", "label": "PATTY"},
		{"item_id": "air_mineral", "label": "AIR MINERAL"},
		{"item_id": "soda", "label": "SODA"},
	],
	"RICE_STORAGE": [
		{"item_id": "nasi", "label": "NASI"},
	],
	"BUN_STORAGE": [
		{"item_id": "bun_burger", "label": "BUN BURGER"},
	],
	"PRODUCE": [
		{"item_id": "buah", "label": "BUAH"},
		{"item_id": "sayur", "label": "SAYUR"},
	],
	"SEASONING": [
		{"item_id": "bumbu", "label": "BUMBU"},
	],
}



static func get_items(workstation_command: String) -> Array:
	return ITEMS.get(workstation_command.to_upper(), []).duplicate(true)


static func has_items(workstation_command: String) -> bool:
	return ITEMS.has(workstation_command.to_upper())
