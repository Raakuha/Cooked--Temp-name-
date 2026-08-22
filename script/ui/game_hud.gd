class_name GameHUD
extends CanvasLayer

@onready var profit_label : Label =$MarginContainer/VBoxContainer/ProfitLabel

## Drag DeadlineLabel (Label baru) ke sini buat nampilin sisa waktu order.
@export var deadline_label: Label

## Drag node MenuDeadlineTimer ke sini biar HUD tau kapan mulai/berhenti
## nge-countdown. Kalau kosong, countdown-nya cuma gak aktif (gak error).
@export var menu_deadline_timer: MenuDeadlineTimer

## Ambang batas (detik) buat mulai kasih warning visual (teks jadi merah).
@export var deadline_warning_seconds: float = 15.0

var _watching_deadline: bool = false


func _ready() -> void:
	if deadline_label != null:
		deadline_label.visible = false

	if menu_deadline_timer != null:
		menu_deadline_timer.deadline_started.connect(_on_deadline_started)
		menu_deadline_timer.deadline_expired.connect(_on_deadline_expired)

	set_process(menu_deadline_timer != null)


func update_profit(value: int) -> void:
	profit_label.text = "Profit : Rp " + str(value)


func _on_deadline_started(_recipe_id: String, _duration: float) -> void:
	_watching_deadline = true

	if deadline_label != null:
		deadline_label.visible = true
		deadline_label.remove_theme_color_override("font_color")


func _on_deadline_expired(_recipe_id: String) -> void:
	if deadline_label != null:
		deadline_label.text = "WAKTU HABIS!"


func _process(_delta: float) -> void:
	if not _watching_deadline or deadline_label == null:
		return

	# Order gagal karena telat -- biarin "WAKTU HABIS!" nempel di layar
	# sampai order berikutnya mulai (deadline_started bakal reset ini).
	if menu_deadline_timer.is_expired():
		return

	if not menu_deadline_timer.is_running():
		# Order selesai duluan sebelum deadline -- gak perlu nampilin apa2.
		_watching_deadline = false
		deadline_label.visible = false
		return

	var remaining: float = menu_deadline_timer.get_remaining_time()

	deadline_label.text = _format_time(remaining)

	if remaining <= deadline_warning_seconds:
		deadline_label.add_theme_color_override("font_color", Color.RED)


func _format_time(seconds: float) -> String:
	var whole: int = int(ceil(seconds))
	var minutes: int = whole / 60
	var secs: int = whole % 60

	return "%d:%02d" % [minutes, secs]
