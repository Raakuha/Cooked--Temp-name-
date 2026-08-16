extends Node
class_name MenuDeadlineTimer

## R-P3-11 --- Menu Cooking Deadline Timer.
##
## CATATAN PENTING: Bagian isi R-P3-11 di dokumen roadmap REV5 kosong --
## judulnya ada, tapi Scope/DoD-nya tidak sengaja tidak tertulis di
## dokumennya (loncat langsung ke bagian 3). Implementasi di bawah ini
## disusun dari referensi silang yang ADA di dokumen yang sama:
##   - Final Master Issue Order: "Per-menu deadline; late result feeds
##     the existing negative-profit flow without changing the dish."
##   - R-P3-06 scope: "menu-timer expiry" jadi salah satu input result
##     contract; deadline TIDAK PERNAH mengubah hasil masakan.
##   - Updated Execution Plan: "Deadline state ... reset per order."
## Kalau asumsi ini meleset dari maksud aslinya, kasih tau -- struktur
## file ini sengaja dibikin kecil & berdiri sendiri (cuma dengar sinyal
## publik CookingSequenceManager, tidak mengubah isi CSM sama sekali,
## sesuai Ownership Lock: CSM = contract milik Teammate) supaya gampang
## disesuaikan tanpa bongkar banyak kode lain.

## Menyala saat deadline mulai berjalan untuk sebuah order/recipe.
signal deadline_started(recipe_id: String, duration: float)

## Menyala PERSIS SEKALI kalau waktu habis sebelum recipe selesai.
## Tidak pernah meng-hard-fail recipe -- cuma informasi buat konsumen
## di luar (nanti R-P3-06 / Profit-Sanity flow) yang memutuskan efeknya.
signal deadline_expired(recipe_id: String)

## Menyala setiap kali timer direset untuk order baru.
signal deadline_reset(recipe_id: String)

## Deadline default (detik) kalau recipe_id tidak ada di RecipeData.DEADLINES.
@export var default_deadline_seconds: float = 90.0

## Hubungkan ke CookingSequenceManager yang sudah ada di scene (drag di
## Inspector). Timer ini CUMA MENDENGARKAN sinyal publik CSM
## (recipe_started/recipe_completed) -- tidak pernah memodifikasi CSM.
@export var cooking_sequence_manager: CookingSequenceManager

var _time_left: float = 0.0
var _running: bool = false
var _expired: bool = false
var _recipe_id: String = ""


func _ready() -> void:
	set_process(false)

	if cooking_sequence_manager == null:
		push_warning(
			"MenuDeadlineTimer: cooking_sequence_manager belum dipasang."
		)
		return

	cooking_sequence_manager.recipe_started.connect(_on_recipe_started)
	cooking_sequence_manager.recipe_completed.connect(_on_recipe_completed)


func _on_recipe_started(recipe_id: String) -> void:
	_recipe_id = recipe_id
	_time_left = get_deadline_for(recipe_id)
	_running = true
	_expired = false
	set_process(true)

	deadline_reset.emit(recipe_id)
	deadline_started.emit(recipe_id, _time_left)


func _on_recipe_completed(_result) -> void:
	_running = false
	set_process(false)


func _process(delta: float) -> void:
	if not _running or _expired:
		return

	_time_left -= delta

	if _time_left <= 0.0:
		_time_left = 0.0
		_expired = true
		_running = false
		set_process(false)

		print(
			"[MenuDeadlineTimer] Deadline habis untuk: ",
			_recipe_id
		)

		# R-P3-06 --- laporkan ke CookingResult lewat hook yang CSM sediain.
		# MenuDeadlineTimer TIDAK menyentuh Profit/Sanity langsung.
		if cooking_sequence_manager != null:
			cooking_sequence_manager.mark_deadline_expired()

		deadline_expired.emit(_recipe_id)


## Ambil deadline (detik) untuk recipe_id tertentu. Kalau tidak ada
## override di RecipeData.DEADLINES, pakai default_deadline_seconds.
func get_deadline_for(recipe_id: String) -> float:
	return RecipeData.DEADLINES.get(recipe_id, default_deadline_seconds)


func is_expired() -> bool:
	return _expired
	


func is_running() -> bool:
	return _running

func get_remaining_time() -> float:
	return _time_left


func get_recipe_id() -> String:
	return _recipe_id
