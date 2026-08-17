class_name CustomerDatabase
extends Node


var profiles: Dictionary = {}


func register_profile(
	customer_id: String,
	profile: CustomerProfile
) -> void:

	profiles[customer_id] = profile


func get_profile(customer_id: String) -> CustomerProfile:

	if not profiles.has(customer_id):
		print("Customer profile tidak ditemukan: ", customer_id)
		return null

	return profiles[customer_id]
