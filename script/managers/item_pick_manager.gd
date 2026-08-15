extends Node
class_name ItemPickManager

## R-P3-10 extension --- "Ambil barang yang benar dari beberapa pilihan".
##
## Dipakai HANYA untuk step TAKE di workstation yang punya lebih dari satu
## barang (mis. Kulkas isi daging cincang, daging wagyu, butter, air
## mineral, soda). SEMUA nama barang ditampilkan sekaligus; player bebas
## ngetik salah satu -- gak ada "pilih dulu baru ngetik".
##
## Aturan ketik: SPASI TIDAK DIKETIK. Label ditampilkan dengan spasi (mis.
## "DAGING CINCANG") tapi yang diketik player "DAGINGCINCANG" -- matching
## selalu dilakukan terhadap versi label yang spasinya dibuang
## (lihat strip_label()). Nekan spasi diabaikan sama sekali.
##
## Kontrak penting (sama pola kayak StoveTimingUI/CookingResult):
##   - ItemPickManager TIDAK PERNAH tau barang mana yang "benar" menurut
##     resep aktif. Dia cuma balikin barang APA yang berhasil diketik PAS
##     oleh player. Workstation (pemanggil) yang bandingin ke
##     `interaction.item_id` dari RecipeData dan mutusin benar/salah.
##   - Salah ketik SEBAGIAN kata (typo, huruf gak cocok prefix barang
##     manapun) != salah pilih barang. Salah ketik cuma nge-block huruf itu
##     (persis kayak TypingManager biasa). Salah PILIH barang baru
##     kejadian kalau player berhasil ngetik PAS satu nama barang yang utuh
##     tapi itu bukan yang dibutuhkan -- itu urusan run_return() di bawah.

signal pick_started(candidates: Array)
signal pick_updated(states: Array)  # Array of {item_id,label,matched_len,had_mistake}
signal pick_completed(result: Dictionary)  # {"item_id":String,"label":String}
signal pick_confirm_rejected()  # ENTER ditekan tapi buffer belum PAS 1 barang

signal return_started(label: String)
signal return_updated(matched_len: int, target: String, had_mistake: bool)
signal return_completed(label: String)

signal exit_wait_started(label: String)
signal exit_wait_completed()

var _candidates: Array = []
var _buffer: String = ""
var _picking: bool = false

var _return_target: String = ""
var _return_fill: String = ""
var _returning: bool = false

var _waiting_exit: bool = false


## Buang semua spasi dari label, dipakai buat matching DAN dipanggil UI
## buat nerjemahin posisi "sudah diketik berapa huruf" balik ke label asli
## (yang ada spasinya) buat ditampilin.
static func strip_label(label: String) -> String:
	return label.replace(" ", "")


## Nunjukkin semua candidate sekaligus, nunggu player ngetik salah satu
## SAMPAI PAS (full match, tanpa spasi). Balikin {"item_id":.., "label":..}.
func run_pick(candidates: Array) -> Dictionary:
	_candidates = candidates.duplicate(true)
	_buffer = ""
	_picking = true

	pick_started.emit(_candidates.duplicate(true))
	_emit_pick_state()

	var result: Dictionary = await pick_completed
	return result


## "Taruh balik" barang yang salah diambil -- player ngetik ulang nama
## barangnya (tanpa spasi, persis 1 target aja) buat naruh balik. Ini yang
## bikin salah pilih barang "buang waktu" beneran, bukan cuma penalty angka.
func run_return(label: String) -> void:
	_return_target = label
	_return_fill = ""
	_returning = true

	return_started.emit(label)
	return_updated.emit(0, _return_target, false)

	await return_completed


## Dipanggil SETELAH barang yang benar berhasil diambil. Player tetap
## "stay" di workstation (belum complete_action()) sampai dia sendiri
## yang nekan BACKSPACE buat keluar. Ini kasih jeda konfirmasi eksplisit
## yang diminta -- gak ada auto-keluar begitu ambil barang.
func wait_for_exit(label: String) -> void:
	_waiting_exit = true

	exit_wait_started.emit(label)

	await exit_wait_completed


func _confirm_exit() -> void:
	_waiting_exit = false
	exit_wait_completed.emit()


func _unhandled_key_input(event: InputEvent) -> void:
	if not (_picking or _returning or _waiting_exit):
		return

	if not event is InputEventKey:
		return

	# Input Map: "item_pick_exit" (Backspace) -- cuma berlaku pas nunggu
	# exit setelah barang BENAR udah diambil.
	if event.is_action_pressed("item_pick_exit"):
		if _waiting_exit:
			_confirm_exit()
			get_viewport().set_input_as_handled()
		return

	# Input Map: "item_pick_confirm" (Enter/Numpad Enter) -- cuma berlaku
	# pas lagi PICKING, buat konfirmasi barang secara eksplisit. Ini yang
	# nyelesain masalah ambiguitas prefix (mis. "DAGING" vs "DAGING
	# CINCANG") -- gak ada lagi auto-commit begitu buffer PAS sama satu
	# label utuh.
	if event.is_action_pressed("item_pick_confirm"):
		if _picking:
			_try_confirm_pick()
			get_viewport().set_input_as_handled()
		return

	var key := event as InputEventKey

	if not key.pressed or key.echo:
		return

	if key.unicode == 0:
		return

	var input := String.chr(key.unicode).to_upper()

	# Spasi SENGAJA tidak ada di daftar ini -- nekan spasi diabaikan total,
	# bukan dianggap salah ketik ataupun bagian dari kata.
	if not "ABCDEFGHIJKLMNOPQRSTUVWXYZ".contains(input):
		return

	if _picking:
		_check_pick(input)
	elif _returning:
		_check_return(input)

	get_viewport().set_input_as_handled()


func _check_pick(input: String) -> void:
	var next_buffer: String = _buffer + input

	var still_matching: Array = []

	for candidate in _candidates:
		var stripped: String = strip_label(candidate["label"])

		if stripped.length() >= next_buffer.length() \
			and stripped.substr(0, next_buffer.length()) == next_buffer:
			still_matching.append(candidate)

	if still_matching.is_empty():
		# Gak ada barang yang cocok sama sekali -- typo biasa, buffer gak
		# maju, cuma kasih feedback error.
		_emit_pick_state(true)
		return

	_buffer = next_buffer
	_emit_pick_state(false)

	# CATATAN: sengaja TIDAK ADA auto-commit di sini lagi, walaupun
	# _buffer udah PAS sama satu label utuh (mis. "DAGING"). Kalau masih
	# ada kandidat lain yang lebih panjang dengan prefix sama (mis.
	# "DAGINGCINCANG"), player harus tetap bisa lanjut ngetik. Barang
	# baru ke-pick kalau player secara eksplisit nekan ENTER lewat
	# _try_confirm_pick().


## Dipanggil pas ENTER ditekan selagi _picking. Kalau _buffer PAS sama
## satu label utuh (tanpa spasi), itu yang di-pick -- walaupun masih ada
## kandidat lain yang lebih panjang dengan prefix sama (itu justru
## intinya: ENTER = "ini barang yang gue maksud, bukan mau nerusin ngetik").
func _try_confirm_pick() -> void:
	for candidate in _candidates:
		if strip_label(candidate["label"]) == _buffer:
			_picking = false

			var result: Dictionary = {
				"item_id": candidate["item_id"],
				"label": candidate["label"]
			}

			pick_completed.emit(result)
			return

	# Buffer belum PAS sama barang manapun (mis. baru ketik "DAGI") --
	# ENTER diabaikan, cuma kasih sinyal ke UI biar bisa kasih feedback
	# (flash merah, sama kayak salah ketik).
	pick_confirm_rejected.emit()


func _emit_pick_state(had_mistake: bool = false) -> void:
	var states: Array = []

	for candidate in _candidates:
		var label: String = candidate["label"]
		var stripped: String = strip_label(label)
		var prefix_len: int = min(_buffer.length(), stripped.length())
		var matched_len := 0

		if stripped.substr(0, prefix_len) == _buffer.substr(0, prefix_len):
			matched_len = _buffer.length()

		states.append({
			"item_id": candidate["item_id"],
			"label": label,
			"matched_len": matched_len,  # posisi di LABEL TANPA SPASI
			"had_mistake": had_mistake
		})

	pick_updated.emit(states)


func _check_return(input: String) -> void:
	var stripped_target: String = strip_label(_return_target)
	var next_len: int = _return_fill.length() + 1

	if next_len <= stripped_target.length() \
		and stripped_target.substr(next_len - 1, 1) == input:
		_return_fill += input
		return_updated.emit(_return_fill.length(), _return_target, false)

		if _return_fill.length() == stripped_target.length():
			_returning = false
			var finished := _return_target
			return_completed.emit(finished)
	else:
		return_updated.emit(_return_fill.length(), _return_target, true)
