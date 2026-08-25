class_name DialogueBubble
extends CanvasLayer


@onready var bubble_panel = $Control/BubbleDialog
@onready var bubble_speaker = $Control/BubbleDialog/SpeakerLabel
@onready var bubble_text = $Control/BubbleDialog/DialogueLabel

@onready var fullscreen_panel = $Control/FullscreenDialog
@onready var fullscreen_speaker = $Control/FullscreenDialog/SpeakerLabel
@onready var fullscreen_text = $Control/FullscreenDialog/DialogueLabel


var target : Node3D = null


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

	else:

		fullscreen_panel.show()
		bubble_panel.hide()

		fullscreen_speaker.text = dialog["speaker"]
		fullscreen_text.text = dialog["text"]


func set_target(new_target: Node3D):

	target = new_target

	print("Dialogue target =", target)


func _process(_delta):

	if target == null:
		return

	if not is_instance_valid(target):
		target = null
		return

	var camera = get_viewport().get_camera_3d()

	if camera == null:
		return

	var screen_position = camera.unproject_position(target.global_position)

	bubble_panel.position = screen_position


func hide_dialog():

	target = null

	hide()


func is_open() -> bool:

	return visible
	
