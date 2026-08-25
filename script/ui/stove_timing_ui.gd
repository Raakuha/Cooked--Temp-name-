extends CanvasLayer
class_name StoveTimingUI

signal timing_completed(result: String)

const RESULT_PERFECT := "PERFECT"
const RESULT_GOOD := "GOOD"
const RESULT_MISS := "MISS"

const MAX_VALUE := 100.0

## Berapa detik untuk 1x jarum bolak-balik penuh (0 -> 100 -> 0).
@export var cycle_duration: float = 1.4

## Titik tengah target zone, dalam skala LOGIKA 0-100 (dipakai buat scoring
## evaluate() -- TIDAK otomatis ngubah ukuran gambar zona, soalnya
## GoodZone/PerfectZone sekarang gambar jadi yang cuma di-ROTATE, bukan
## di-resize. Kalau ubah angka ini, inget rotasi manual GoodZone/
## PerfectZone di editor juga perlu disesuaikan biar visual & logika
## nyambung.
@export var target_center: float = 50.0

## Setengah lebar zona PERFECT (dari target_center) -- buat SCORING aja.
@export var perfect_half_width: float = 6.0

## Setengah lebar zona GOOD (dari target_center) -- buat SCORING aja.
@export var good_half_width: float = 16.0

## Nilai penalty yang "disarankan" untuk hasil MISS. Nilai ini CUMA
## disertakan sebagai data hasil -- StoveTimingUI tidak pernah menerapkan
## penalty ini sendiri. R-P3-06 (Cooking Result Contract) yang nanti
## memutuskan cara memakainya.
@export var suggested_miss_penalty: float = 5.0


@export var needle: Control

## Sudut (derajat) jarum saat value = 0.
@export var needle_min_angle: float = -60.0

## Sudut (derajat) jarum saat value = 100.
@export var needle_max_angle: float = 60.0


@export var good_zone: Control

## Sama kayak good_zone, tapi buat segmen PERFECT.
@export var perfect_zone: Control


@export var bar: Range

@export var label: Label

## Opsional -- badge gambar buat hasil PERFECT/GOOD/MISS.
@export var result_badge: TextureRect
@export var perfect_texture: Texture2D
@export var good_texture: Texture2D
@export var miss_texture: Texture2D

var _active: bool = false
var _elapsed: float = 0.0
var _needle_value: float = 0.0
var _round_label: String = "MASAK"

var _timing_session_id : int = 0

func _ready() -> void:
	visible = false
	set_process(false)

	if result_badge != null:
		result_badge.visible = false

	if bar != null:
		bar.min_value = 0.0
		bar.max_value = MAX_VALUE
		bar.value = 0.0

	_layout_zones()


## Dipanggil oleh Workstation. round_label opsional, ditampilkan di label
## (mis. "BALIK", "MASAK") supaya player tahu ronde timing yang mana.
## Return: "PERFECT" / "GOOD" / "MISS"
func run_timing(round_label: String = "") -> String:
	start_timing(round_label)
	var result: String = await timing_completed
	return result


func start_timing(round_label: String = "") -> void:
	_timing_session_id += 1
	if round_label != "":
		_round_label = round_label

	_elapsed = 0.0
	_needle_value = 0.0
	_active = true
	visible = true
	set_process(true)

	_layout_zones()
	_update_label("")


func _process(delta: float) -> void:
	if not _active:
		return

	_elapsed += delta

	# Triangle wave deterministik: 0 -> 1 -> 0 sepanjang cycle_duration.
	var t: float = fmod(_elapsed, cycle_duration) / cycle_duration
	var wave: float = 1.0 - abs(1.0 - (t * 2.0))

	_needle_value = wave * MAX_VALUE

	if needle != null:
		needle.rotation_degrees = _angle_for_value(_needle_value)

	if bar != null:
		bar.value = _needle_value


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
	
	var  session_id := _timing_session_id
	var result := evaluate(
		value,
		target_center,
		perfect_half_width,
		good_half_width
	)

	_update_label(result)

	# Jeda singkat biar player sempat lihat hasilnya sebelum UI hilang.
	await get_tree().create_timer(0.35).timeout
	if session_id != _timing_session_id:
		return
	
	visible = false
	timing_completed.emit(result)


func _update_label(result: String) -> void:
	if label != null:
		if result == "":
			label.text = _round_label + " -- Tekan SPASI di zona target!"
		else:
			label.text = _round_label + " -> " + result

	if result_badge == null:
		return

	if result == "":
		result_badge.visible = false
		return

	result_badge.visible = true

	match result:
		RESULT_PERFECT:
			result_badge.texture = perfect_texture
		RESULT_GOOD:
			result_badge.texture = good_texture
		RESULT_MISS:
			result_badge.texture = miss_texture



func _angle_for_value(value: float) -> float:
	var t: float = value / MAX_VALUE
	return lerp(needle_min_angle, needle_max_angle, t)


## Muter good_zone/perfect_zone (gambar jadi) ke posisi target_center.
## Dipanggil sekali di _ready() dan tiap start_timing() -- bukan tiap
## frame, soalnya zona gak animasi, cuma diem di posisi targetnya.
func _layout_zones() -> void:
	if good_zone != null:
		good_zone.rotation_degrees = _angle_for_value(target_center)

	if perfect_zone != null:
		perfect_zone.rotation_degrees = _angle_for_value(target_center)


## Fungsi MURNI (tidak menyentuh node/scene) supaya gampang di-unit-test
## terpisah. Deterministik: input yang sama selalu menghasilkan output
## yang sama -- ini yang bikin R-P3-09 "testable" sesuai Definition of
## Done. Scoring ini TIDAK bergantung ke visual dial/bar -- tetap pakai
## skala 0-100 yang sama walaupun tampilannya udah muter.
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

func cancel() -> void:
	if not _active:
		return
	_timing_session_id += 1
	_active = false
	set_process(false)
	visible = false
	
	if result_badge != null:
		result_badge.visible = false
	timing_completed.emit("CANCELED")
