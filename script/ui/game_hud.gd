extends CanvasLayer
class_name GameHUD


@export var menu_deadline_timer: MenuDeadlineTimer
@export var deadline_warning_seconds: float = 15.0


@onready var profit_label: Label = (
	$HudRoot/ProfitChip/ProfitLabel
)

@onready var dial: RadialTimer = (
	$HudRoot/DialArea/Dial
)

@onready var caption_label: Label = (
	$HudRoot/DialArea/TextCenter/TextCol/CaptionLabel
)

@onready var time_label: Label = (
	$HudRoot/DialArea/TextCenter/TextCol/TimeLabel
)


var _watching_deadline: bool = false
var _order_total_duration: float = 1.0


func _ready() -> void:
	visible = false
	if menu_deadline_timer == null:
		push_warning(
			"[GameHUD] MenuDeadlineTimer belum dipasang."
		)
		return

	menu_deadline_timer.deadline_started.connect(
		_on_deadline_started
	)

	menu_deadline_timer.deadline_expired.connect(
		_on_deadline_expired
	)

	dial.visible = false
	time_label.text = "0:00"
	caption_label.text = "ORDER"

	set_process(true)


func update_profit(value: int) -> void:
	profit_label.text = "Rp " + str(value)


func _on_deadline_started(
	_unused_recipe_id: String,
	duration: float
) -> void:

	_order_total_duration = max(duration, 0.01)
	_watching_deadline = true

	dial.visible = true

	caption_label.text = "ORDER"
	time_label.text = _format_time(duration)

	dial.set_timer(
		duration,
		_order_total_duration
	)


func _on_deadline_expired() -> void:
	_watching_deadline = false

	dial.visible = true

	caption_label.text = "ORDER"
	time_label.text = "0:00"

	dial.set_timer(
		0.0,
		_order_total_duration
	)


func _process(_delta: float) -> void:
	if not _watching_deadline:
		return

	if menu_deadline_timer == null:
		return

	var remaining := (
		menu_deadline_timer.get_remaining_time()
	)

	if not menu_deadline_timer.is_running():
		return

	time_label.text = _format_time(remaining)

	dial.set_timer(
		remaining,
		_order_total_duration
	)


func _format_time(seconds: float) -> String:
	var whole := int(ceil(max(seconds, 0.0)))

	var minutes := whole / 60
	var secs := whole % 60

	return "%d:%02d" % [minutes, secs]
func show_game_hud() -> void:
	visible = true


func hide_game_hud() -> void:
	visible = false
