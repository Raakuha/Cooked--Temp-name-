class_name CustomerDatabase
extends Node

@export var profiles: Array[CustomerProfile] = []

var profile_map: Dictionary = {}


func _ready() -> void:

	for profile in profiles:

		if profile == null:
			continue

		if profile.character_id.is_empty():
			print("Profile customer tidak memiliki ID.")
			continue

		profile_map[profile.character_id] = profile

	print("========================")
	print("CUSTOMER DATABASE READY")
	print("Profiles :", profile_map.size())
	print("========================")


func get_profile(customer_id: String) -> CustomerProfile:

	if not profile_map.has(customer_id):

		print(
			"Customer ID tidak ditemukan di database: ",
			customer_id
		)

		return null

	return profile_map[customer_id]
