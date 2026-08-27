extends HBoxContainer
class_name ItemPickRow

@onready var check_icon: TextureRect = $CheckIcon
@onready var item_label: RichTextLabel = $ItemLabel

@export var empty_texture: Texture2D
@export var completed_texture: Texture2D

func _ready() -> void:
	item_label.bbcode_enabled = true
	item_label.fit_content = true
	item_label.scroll_active = false
	item_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	item_label.custom_minimum_size = Vector2(340, 28)

func set_item_label(
	label: String,
	matched_len: int
) -> void:

	var visual_len : int = _visual_length(
		label,
		matched_len
	)

	var clamped_len : int = clampi(
		visual_len,
		0,
		label.length()
	)

	var completed := label.substr(
		0,
		clamped_len
	)

	var remaining := label.substr(
		clamped_len
	)

	item_label.text = (
		"[color=#ffad72]"
		+ completed
		+ "[/color]"
		+ "[color=#FFFFFF55]"
		+ remaining
		+ "[/color]"
	)


func set_completed() -> void:
	if completed_texture != null:
		check_icon.texture = completed_texture


func set_pending() -> void:
	if empty_texture != null:
		check_icon.texture = empty_texture


static func _visual_length(
	label: String,
	stripped_matched_len: int
) -> int:

	if stripped_matched_len <= 0:
		return 0

	var seen : int = 0

	for i in label.length():
		if label[i] != " ":
			seen += 1

			if seen == stripped_matched_len:
				return i + 1

	return label.length()
