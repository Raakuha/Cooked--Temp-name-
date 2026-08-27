extends HBoxContainer
class_name PrepChecklistRow

@onready var check_icon: TextureRect = $CheckIcon
@onready var item_label: Label = $ItemLabel

@export var empty_texture: Texture2D
@export var completed_texture: Texture2D

@export var completed_color: Color = Color(0.6, 1.0, 0.6, 1.0)
@export var pending_color: Color 


func setup(
	_checklist_id: String,
	display_name: String,
	done: bool
) -> void:

	item_label.text = display_name

	if done:
		if completed_texture != null:
			check_icon.texture = completed_texture

		item_label.modulate = completed_color

	else:
		if empty_texture != null:
			check_icon.texture = empty_texture

		item_label.modulate = pending_color
