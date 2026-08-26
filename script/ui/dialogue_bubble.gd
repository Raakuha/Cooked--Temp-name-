#class_name DialogueBubble
#extends CanvasLayer
#
#
#@onready var bubble_panel = $Control/BubbleDialog
#@onready var bubble_speaker = $Control/BubbleDialog/SpeakerTag/SpeakerLabel
#@onready var bubble_text = $Control/BubbleDialog/DialogueLabel
#
#@onready var fullscreen_panel = $Control/FullscreenDialog
#@onready var fullscreen_speaker = $Control/FullscreenDialog/SpeakerLabel
#@onready var fullscreen_text = $Control/FullscreenDialog/DialogueLabel
#
#
#var target : Node3D = null
#
#
#
#const BUBBLE_MIN_WIDTH := 500.0
#const BUBBLE_MAX_WIDTH := 700.0
#
#const BUBBLE_MIN_HEIGHT := 105.0
#const BUBBLE_MAX_HEIGHT := 220.0
#
#const TEXT_HORIZONTAL_PADDING := 35.0
#const TEXT_TOP_PADDING := 38.0
#const TEXT_BOTTOM_PADDING := 30.0
#
#const SPEAKER_MIN_WIDTH := 110.0
#const SPEAKER_MAX_WIDTH := 200.0
#const SPEAKER_HORIZONTAL_PADDING := 24.0
#
#
#
#func _ready():
#
	#hide()
#
	#print("========================")
	#print("DIALOGUE BUBBLE READY")
	#print(self)
	#print("========================")
#
#
#func show_dialog(dialog):
#
	#print("SHOW_DIALOG DIPANGGIL")
#
	#show()
#
	#if dialog["mode"] == "bubble":
#
		#bubble_panel.show()
		#fullscreen_panel.hide()
#
		#bubble_speaker.text = dialog["speaker"]
		#bubble_text.text = dialog["text"]
#
	#else:
#
		#fullscreen_panel.show()
		#bubble_panel.hide()
#
		#fullscreen_speaker.text = dialog["speaker"]
		#fullscreen_text.text = dialog["text"]
#
#
#func set_target(new_target: Node3D):
#
	#target = new_target
#
	#print("Dialogue target =", target)
#
#
##func _process(_delta):
##
	##if target == null:
		##return
##
	##if not is_instance_valid(target):
		##target = null
		##return
##
	##var camera = get_viewport().get_camera_3d()
##
	##if camera == null:
		##return
##
	##var screen_position = camera.unproject_position(target.global_position)
##
	##bubble_panel.position = screen_position
#
#
#func _process(_delta):
#
	#if target == null:
		#return
#
	#if not is_instance_valid(target):
		#target = null
		#return
#
	#var camera = get_viewport().get_camera_3d()
#
	#if camera == null:
		#return
#
	#var screen_position = camera.unproject_position(
		#target.global_position
	#)
#
	#var viewport_size := get_viewport().get_visible_rect().size
#
	#var bubble_position := Vector2(
		#screen_position.x - bubble_panel.size.x / 2.0,
		#screen_position.y - bubble_panel.size.y - 30.0
	#)
#
	#bubble_position.x = clamp(
		#bubble_position.x,
		#20.0,
		#viewport_size.x - bubble_panel.size.x - 20.0
	#)
#
	#bubble_position.y = max(
		#bubble_position.y,
		#20.0
	#)
#
	#bubble_panel.position = bubble_position
#
#
#
#func hide_dialog():
#
	#target = null
#
	#hide()
#
#
#func is_open() -> bool:
#
	#return visible







class_name DialogueBubble
extends CanvasLayer


@onready var bubble_panel: Panel = $Control/BubbleDialog
@onready var bubble_speaker: Label = $Control/BubbleDialog/SpeakerTag/SpeakerLabel
@onready var bubble_text: Label = $Control/BubbleDialog/DialogueLabel

@onready var fullscreen_panel = $Control/FullscreenDialog
@onready var fullscreen_speaker = $Control/FullscreenDialog/SpeakerLabel
@onready var fullscreen_text = $Control/FullscreenDialog/DialogueLabel


const BUBBLE_MIN_WIDTH := 300.0
const BUBBLE_MAX_WIDTH := 700.0

const BUBBLE_MIN_HEIGHT := 105.0
const BUBBLE_MAX_HEIGHT := 220.0

const TEXT_LEFT_PADDING := 35.0
const TEXT_RIGHT_PADDING := 70.0

const TEXT_TOP_PADDING := 38.0
const TEXT_BOTTOM_PADDING := 30.0

const SPEAKER_MIN_WIDTH := 110.0
const SPEAKER_MAX_WIDTH := 200.0
const SPEAKER_HORIZONTAL_PADDING := 24.0


var target: Node3D = null


func _ready():

	hide()

	print("========================")
	print("DIALOGUE BUBBLE READY")
	print(self)
	print("========================")


func show_dialog(dialog):

	print("SHOW_DIALOG DIPANGGIL")

	show()

	if dialog["mode"] == "bubble":

		bubble_panel.show()
		fullscreen_panel.hide()

		bubble_speaker.text = dialog["speaker"]
		bubble_text.text = dialog["text"]

		call_deferred("_update_bubble_layout")
	else:

		fullscreen_panel.show()
		bubble_panel.hide()

		fullscreen_speaker.text = dialog["speaker"]
		fullscreen_text.text = dialog["text"]

		fullscreen_panel.move_to_front()


func _update_bubble_layout() -> void:

	if not bubble_panel.visible:
		return

	var viewport_width: float = (
		get_viewport()
		.get_visible_rect()
		.size.x
	)

	var font: Font = bubble_text.get_theme_font("font")
	var font_size: int = bubble_text.get_theme_font_size("font_size")

	var text_size := font.get_string_size(
		bubble_text.text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size
	)

	var desired_width: float = (
		text_size.x
		+ TEXT_LEFT_PADDING
		+ TEXT_RIGHT_PADDING
	)

	var bubble_width: float = clampf(
		desired_width,
		BUBBLE_MIN_WIDTH,
		minf(
			BUBBLE_MAX_WIDTH,
			viewport_width - 40.0
		)
	)

	bubble_panel.size.x = bubble_width


	var text_width: float = (
		bubble_width
		- TEXT_LEFT_PADDING
		- TEXT_RIGHT_PADDING
	)

	bubble_text.position.x = TEXT_LEFT_PADDING
	bubble_text.size.x = text_width


	await get_tree().process_frame


	var text_height: float = (
		bubble_text.get_combined_minimum_size().y
	)


	var bubble_height: float = (
		text_height
		+ TEXT_TOP_PADDING
		+ TEXT_BOTTOM_PADDING
	)

	bubble_height = clampf(
		bubble_height,
		BUBBLE_MIN_HEIGHT,
		BUBBLE_MAX_HEIGHT
	)

	bubble_panel.size.y = bubble_height


	bubble_text.position.y = TEXT_TOP_PADDING

	bubble_text.size.y = (
		bubble_height
		- TEXT_TOP_PADDING
		- TEXT_BOTTOM_PADDING
	)


	var speaker_width: float = (
		bubble_speaker.get_combined_minimum_size().x
		+ SPEAKER_HORIZONTAL_PADDING * 2.0
	)

	speaker_width = clampf(
		speaker_width,
		SPEAKER_MIN_WIDTH,
		SPEAKER_MAX_WIDTH
	)


	var speaker_tag: Control = bubble_speaker.get_parent()

	speaker_tag.size.x = speaker_width

	speaker_tag.position.x = 30.0
	speaker_tag.position.y = -20.0


	var continue_icon: Control = (
		bubble_panel.get_node("ContinueIcon")
	)

	continue_icon.position.x = (
		bubble_width
		- continue_icon.size.x
		- 20.0
	)

	continue_icon.position.y = (
		bubble_height
		- continue_icon.size.y
		- 15.0
	)


	_update_bubble_position()


func _update_bubble_position() -> void:

	if target == null:
		return

	if not is_instance_valid(target):
		target = null
		return

	var camera := get_viewport().get_camera_3d()

	if camera == null:
		return

	var screen_position := camera.unproject_position(
		target.global_position
	)

	var viewport_size := (
		get_viewport()
		.get_visible_rect()
		.size
	)

	var bubble_position := Vector2(
		screen_position.x
		- bubble_panel.size.x / 2.0,

		screen_position.y
		- bubble_panel.size.y
		- 30.0
	)

	bubble_position.x = max(
		bubble_position.x,
		20.0
	)

	bubble_position.x = min(
		bubble_position.x,
		viewport_size.x
		- bubble_panel.size.x
		- 20.0
	)

	bubble_position.y = max(
		bubble_position.y,
		20.0
	)

	bubble_panel.position = bubble_position


func set_target(new_target: Node3D):

	target = new_target

	print("Dialogue target =", target)


func _process(_delta):

	if target == null:
		return

	if not is_instance_valid(target):
		target = null
		return

	if not bubble_panel.visible:
		return

	_update_bubble_position()


func hide_dialog():

	target = null

	hide()


func is_open() -> bool:

	return visible
