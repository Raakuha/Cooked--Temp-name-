extends CanvasLayer
class_name StoveTimingUI

## R-P3-09 --- Simple Stove Temperature Timing.
##
## Skill-window sederhana, BUKAN heat simulation. "Jarum" (TimingBar.value)
## bergerak bolak-balik secara DETERMINISTIK (triangle wave, bukan random)
## di sepanjang gauge 0-100. Player menekan SPASI untuk mengunci posisi
## jarum saat itu -> dibandingkan ke target zone -> PERFECT / GOOD / MISS.
##
## Dipasang di atas node scene yang sudah ada (Timing_mekanisme.tscn):
##   Control/PanelContainer/VBoxContainer/TemperatureLabel (Label)
##   Control/PanelContainer/VBoxContainer/TimingBar (ProgressBar)
##
## Kontrak penting (jangan dilanggar saat extend):
##   - Tidak pernah memanggil Profit/Sanity/mental system langsung dari sini.
##   - Hasil MISS tidak pernah mengubah dish/recipe menjadi gagal; hasil
##     cuma dikembalikan ke pemanggil (Workstation) lewat sinyal/return.
##   - evaluate() adalah fungsi murni supaya gampang di-unit-test terpisah
##     dari node/scene (deterministik: input sama -> output sama).

signal timing_completed(result: String)

const RESULT_PERFECT := "PERFECT"
const RESULT_GOOD := "GOOD"
const RESULT_MISS := "MISS"

const MAX_VALUE := 100.0

## Berapa detik untuk 1x jarum bolak-balik penuh (0 -> 100 -> 0).
@export var cycle_duration: float = 1.4

## Titik tengah target zone, dalam skala gauge 0-100.
@export var target_center: float = 50.0

## Setengah lebar zona PERFECT (dari target_center).
@export var perfect_half_width: float = 6.0

## Setengah lebar zona GOOD (dari target_center, harus >= perfect_half_width).
@export var good_half_width: float = 16.0

## Nilai penalty yang "disarankan" untuk hasil MISS. Nilai ini CUMA
## disertakan sebagai data hasil -- StoveTimingUI tidak pernah menerapkan
## penalty ini sendiri. R-P3-06 (Cooking Result Contract) yang nanti
## memutuskan cara memakainya.
@export var suggested_miss_penalty: float = 5.0

@onready var _label: Label = $Control/PanelContainer/VBoxContainer/TemperatureLabel
@onready var _bar: ProgressBar = $Control/PanelContainer/VBoxContainer/TimingBar

var _good_zone: ColorRect
var _perfect_zone: ColorRect

var _active: bool = false
var _elapsed: float = 0.0
var _needle_value: float = 0.0
var _round_label: String = "MASAK"


func _ready() -> void:
	visible = false
	set_process(false)

	_bar.min_value = 0.0
	_bar.max_value = MAX_VALUE
	_bar.value = 0.0

	_build_zone_overlays()
	_bar.resized.connect(_layout_zone_overlays)
	_layout_zone_overlays()


## Dipanggil oleh Workstation. round_label opsional, ditampilkan di label
## (mis. "BALIK", "MASAK") supaya player tahu ronde timing yang mana.
## Return: "PERFECT" / "GOOD" / "MISS"
func run_timing(round_label: String = "") -> String:
	start_timing(round_label)
	var result: String = await timing_completed
	return result


func start_timing(round_label: String = "") -> void:
	if round_label != "":
		_round_label = round_label

	_elapsed = 0.0
	_needle_value = 0.0
	_active = true
	visible = true
	set_process(true)

	_layout_zone_overlays()
	_update_label("")


func _process(delta: float) -> void:
	if not _active:
		return

	_elapsed += delta

	# Triangle wave deterministik: 0 -> 1 -> 0 sepanjang cycle_duration.
	var t := fmod(_elapsed, cycle_duration) / cycle_duration
	var wave : float = 1.0 - abs(1.0 - (t * 2.0))

	_needle_value = wave * MAX_VALUE
	_bar.value = _needle_value


func _unhandled_key_input(event: InputEvent) -> void:
	if not _active:
		return

	if not event is InputEventKey:
		return

	var key := event as InputEventKey

	if not key.pressed or key.echo:
		return

	if key.keycode != KEY_SPACE:
		return

	_confirm(_needle_value)
	get_viewport().set_input_as_handled()


func _confirm(value: float) -> void:
	_active = false
	set_process(false)

	var result := evaluate(
		value,
		target_center,
		perfect_half_width,
		good_half_width
	)

	_update_label(result)

	# Jeda singkat biar player sempat lihat hasilnya sebelum UI hilang.
	await get_tree().create_timer(0.35).timeout

	visible = false
	timing_completed.emit(result)


func _update_label(result: String) -> void:
	if _label == null:
		return

	if result == "":
		_label.text = _round_label + " -- Tekan SPASI di zona target!"
	else:
		_label.text = _round_label + " -> " + result


func _build_zone_overlays() -> void:
	_good_zone = ColorRect.new()
	_good_zone.color = Color(0.9, 0.7, 0.1, 0.35)
	_good_zone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bar.add_child(_good_zone)

	_perfect_zone = ColorRect.new()
	_perfect_zone.color = Color(0.2, 0.85, 0.3, 0.55)
	_perfect_zone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bar.add_child(_perfect_zone)


func _layout_zone_overlays() -> void:
	if _bar.size.x <= 0.0:
		return

	_position_zone(_good_zone, target_center, good_half_width)
	_position_zone(_perfect_zone, target_center, perfect_half_width)


func _position_zone(zone: ColorRect, center: float, half_width: float) -> void:
	var px_per_unit := _bar.size.x / MAX_VALUE
	var start_x := (center - half_width) * px_per_unit
	var width_px := (half_width * 2.0) * px_per_unit

	zone.position = Vector2(start_x, 0.0)
	zone.size = Vector2(width_px, _bar.size.y)


## Fungsi MURNI (tidak menyentuh node/scene) supaya gampang di-unit-test
## terpisah. Deterministik: input yang sama selalu menghasilkan output
## yang sama -- ini yang bikin R-P3-09 "testable" sesuai Definition of Done.
static func evaluate(
	value: float,
	center: float,
	perfect_half_width: float,
	good_half_width: float
) -> String:
	var distance: float = abs(value - center)

	if distance <= perfect_half_width:
		return RESULT_PERFECT

	if distance <= good_half_width:
		return RESULT_GOOD

	return RESULT_MISS
