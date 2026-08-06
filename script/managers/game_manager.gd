class_name GameManager
extends Node


@export var customer_manager : CustomerManager


func _ready():

	start_day()


func start_day():

	print("===== DAY START =====")

	customer_manager.spawn_customer()
