class_name CustomerProfile
extends Resource

@export var character_id: String = ""
@export var character_name: String = ""





# Identitas visual
@export var model_scene: PackedScene

# Conversation
@export var opening_dialogue: Array[Dictionary] = []
@export var closing_dialogue: Array[Dictionary] = []

# Order
@export var recipe_id: String = ""
@export var additional_orders: Array[String] = []

# Behavior
@export var dining_time: float = 5.0

# Group
@export var group_id: String = ""
@export var group_role: String = ""



@export_category("Mika Day 6 Variant")

@export var day6_opening_dialogue: Array[Dictionary] = []
@export var day6_recipe_id: String = ""
@export var day6_additional_orders: Array[String] = []
@export var day6_closing_dialogue: Array[Dictionary] = []
