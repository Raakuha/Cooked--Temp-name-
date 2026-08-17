class_name CustomerProfile
extends Resource

@export var character_id: String = ""
@export var character_name: String = ""

@export var model_scene: PackedScene

@export var opening_dialogue: Array[Dictionary] = []
@export var recipe_id: String = ""

@export var closing_dialogue: Array[Dictionary] = []

@export var dining_time: float = 5.0
