extends CanvasLayer

signal dialogue_finished

@onready var label = $Control/Panel/Label

enum BubbleMode{
	SMALL,
	LARGE
}

@onready var small_panel = $Control/SmallPanel
@onready var large_panel = $Control/LargePanel

@onready var small_name = $Control/SmallPanel/SpeakerLabel
@onready var small_text = $Control/SmallPanel/DialogueLabel

#func show_dialog(dialog):

	#name_label.text = dialog["speaker"]
#
	#text_label.text = dialog["text"]

func set_mode(mode):

	small_panel.hide()
	large_panel.hide()

	match mode:

		BubbleMode.SMALL:
			small_panel.show()

		BubbleMode.LARGE:
			large_panel.show()

#func hide_dialog():
	#hide()
