class_name PoliceProfile
extends Resource


@export var character_id: String = ""
@export var character_name: String = ""

@export var model_scene: PackedScene

@export var opening_dialogue: Array[Dictionary] = []
@export var restaurant_dialogue: Array[Dictionary] = []

@export var recipe_id: String = ""
@export var additional_orders: Array[String] = []

@export var closing_dialogue: Array[Dictionary] = []
