extends Node3D
class_name Workstation

@export var command : String = ""
@onready var navigation_target: Marker3D = $NavigationTarget
@onready var prompt_anchor: Marker3D = $PromptAnchor
@export var typing_ui: TypingUI
signal interaction_started
signal interaction_finished
signal action_completed(workstation, action_name)

var action_in_progress : bool = false
var current_action: String = ""
var is_interact : bool = false
var current_action_data: Dictionary = {}

@export var camera_controller : CameraController
@export var interaction_camera_anchor : Marker3D
@export var typing_manager: TypingManager

## R-P3-09 --- opsional. Kalau kosong, COOK/FRY fallback ke delay biasa
## (supaya workstation lain yang belum dipasangi timing tidak crash).
@export var stove_timing_ui: StoveTimingUI

## R-P3-10 extension --- opsional. Kalau kosong ATAU step TAKE ini gak
## punya interaction.item_id, TAKE fallback ke delay biasa (workstation
## lama yang belum dipasangi mekanisme pilih barang tidak crash).
@export var item_pick_manager: ItemPickManager

## Hasil PERFECT/GOOD/MISS dari ronde timing terakhir (Array[String]).
## Dibaca nanti oleh R-P3-06 (Cooking Result Contract). Workstation
## sendiri TIDAK memanggil Profit/Sanity langsung dari data ini.
var last_timing_results: Array = []


signal action_started(action_name : String)
signal action_finished(action_name : String)
signal timing_result(workstation: Workstation, action_name: String, results: Array)

## R-P3-10 extension --- fired tiap kali player berhasil ngetik PAS nama
## barang, tapi barang itu BUKAN yang dibutuhkan checklist saat ini.
## Dibaca CookingSequenceManager buat nyatet mistake (persis pola
## timing_result). Workstation sendiri tidak menerapkan penalty apapun.
signal wrong_item_picked(
	workstation: Workstation,
	picked_item_id: String,
	required_item_id: String
)

## R-P3-10 fix --- fired begitu barang yang BENAR berhasil dipetik.
## CookingSequenceManager dengerin ini buat tau checklist_id mana yang
## beneran selesai (bisa beda dari checklist_id yang tadinya "aktif",
## karena sekarang player boleh milih barang lain yang sama-sama eligible
## di workstation yang sama).
signal item_picked(workstation: Workstation, item_id: String)

## Barang terakhir yang beneran kepetik BENAR di workstation ini.
var last_picked_item_id: String = ""

func get_navigation_position() -> Vector3 :
	return navigation_target.global_position
	
func get_prompt_position() -> Vector3:
	return prompt_anchor.global_position
	
func _enter_tree() -> void:
	add_to_group("workstations")

func perform_action(
	action_name: String,
	interaction_data: Dictionary = {}
) -> void:
	if action_in_progress:
		push_warning("Masih ada action yang sedang berjalan.")
		return

	action_in_progress = true
	current_action = action_name
	current_action_data = interaction_data



	action_started.emit(action_name)

	match action_name:
		"TAKE":
			run_take_action()

		"ADD":
			run_add_action()

		"OPEN":
			run_open_action()

		"CLOSE":
			run_close_action()

		"CUT":
			run_cut_action()

		"MIX":
			run_mix_action()

		"COOK":
			run_cook_action()

		"FRY":
			run_fry_action()

		"PLATE":
			run_plate_action()

		"SERVE":
			run_serve_action()

		_:
			push_warning(
				"Action tidak dikenali: " + action_name
			)
			complete_action()
func run_take_action() -> void:
	var required_item_id: String = current_action_data.get("item_id", "")

	# R-P3-10 fix --- "item_ids" (jamak, dari CookingSequenceManager) berisi
	# SEMUA barang yang sah diambil sekarang di workstation ini, bukan cuma
	# 1 required_item_id spesifik. Kalau CookingSequenceManager belum
	# ngirim ini (mis. dipanggil dari test lama), fallback ke required_item_id
	# tunggal dibungkus jadi array 1 elemen -- perilaku lama tetap jalan.
	var required_item_ids: Array = current_action_data.get("item_ids", [])

	if required_item_ids.is_empty() and required_item_id != "":
		required_item_ids = [required_item_id]

	if required_item_ids.is_empty() or item_pick_manager == null:
		# Fallback lama: step ini belum dipasangi item_id (RecipeData) atau
		# workstation-nya belum dipasangi ItemPickManager di scene.
		finish_action_after_delay(0.3)
		return

	var candidates: Array = WorkstationInventory.get_items(command)

	if candidates.is_empty():
		push_warning(
			"WorkstationInventory kosong untuk: " + command
			+ " -- fallback ke delay biasa."
		)
		finish_action_after_delay(0.3)
		return

	var picked_ids_this_visit: Array = []

	while true:
		var picked: Dictionary = await item_pick_manager.run_pick(candidates)

		if picked.get("exit", false):
			# R-P3-10: player boleh keluar tangan kosong (BACKSPACE tanpa
			# ambil apa-apa) -- CookingSequenceManager yang nentuin ini
			# BUKAN "selesai", checklist tetap kosong (lihat
			# _complete_active_prep_item(), bukan di sini).
			break

		if not required_item_ids.has(picked["item_id"]):
			wrong_item_picked.emit(self, picked["item_id"], required_item_id)

			await item_pick_manager.run_return(picked["label"])

			continue

		# Barang udah BENAR (salah satu dari required_item_ids -- player
		# bebas milih yang mana). Catat SEMUA barang yang kepetik di
		# kunjungan ini -- R-P3-10 fix: sebelumnya cuma nyimpen yang
		# TERAKHIR, jadi kalau ambil 2+ barang di 1 kunjungan, yang
		# pertama gak pernah ke-mark selesai checklist-nya.
		last_picked_item_id = picked["item_id"]
		picked_ids_this_visit.append(picked["item_id"])
		item_picked.emit(self, picked["item_id"])

		var remaining: Array = required_item_ids.filter(
			func(id): return not picked_ids_this_visit.has(id)
		)

		if remaining.is_empty():
			# Gak ada barang lain yang masih eligible di workstation ini --
			# otomatis keluar, gak perlu nunggu BACKSPACE tambahan.
			break

		await item_pick_manager.wait_for_exit(picked["label"])
		# BACKSPACE ditekan di sini -> loop balik ke atas, run_pick() lagi.

	complete_action()


func run_add_action() -> void:
	

	finish_action_after_delay(0.3)


func run_open_action() -> void:


	finish_action_after_delay(0.3)


func run_close_action() -> void:


	finish_action_after_delay(0.3)


func run_cut_action() -> void:
	var prompts: Array = current_action_data.get(
		"prompts",
		["CUT"]
	)

	if camera_controller == null:
		push_warning("CameraController belum dipasang.")
		complete_action()
		return

	if interaction_camera_anchor == null:
		push_warning("InteractionCameraAnchor belum dipasang.")
		complete_action()
		return

	if typing_manager == null:
		push_warning("TypingManager belum dipasang.")
		complete_action()
		return

	camera_controller.enter_interaction(
		interaction_camera_anchor
	)

	await camera_controller.transition_finished

	typing_ui.use_screen_mode()

	for prompt in prompts:
		typing_manager.call_deferred(
			"start_typing",
			String(prompt)
		)

		await typing_manager.typing_completed

	camera_controller.exit_interaction()

	typing_ui.use_world_mode()

	await camera_controller.transition_finished

	complete_action()

func run_mix_action() -> void:


	var prompts: Array = current_action_data.get(
		"prompts",
		["MIX"]
	)

	print("[CookingAction] Interaction prompts: ", prompts)

	if camera_controller == null:
		push_warning("CameraController belum dipasang.")
		complete_action()
		return

	if interaction_camera_anchor == null:
		push_warning("InteractionCameraAnchor belum dipasang.")
		complete_action()
		return

	if typing_manager == null:
		push_warning("TypingManager belum dipasang.")
		complete_action()
		return

	camera_controller.enter_interaction(
		interaction_camera_anchor
	)

	await camera_controller.transition_finished
	typing_ui.use_screen_mode()



	for prompt in prompts:
		typing_manager.call_deferred(
			"start_typing",
			String(prompt)
		)

		await typing_manager.typing_completed

		print(
			"[CookingAction] Prompt selesai: ",
			prompt
		)


	camera_controller.exit_interaction()
	typing_ui.use_world_mode()
	await camera_controller.transition_finished

	complete_action()

func run_cook_action() -> void:
	await run_stove_timing_sequence()


func run_fry_action() -> void:
	await run_stove_timing_sequence()


## R-P3-09 --- Dipakai oleh COOK dan FRY. Menjalankan 1 ronde timing per
## item di interaction.prompts (kalau tidak ada, default 1 ronde "COOK"),
## persis pola perulangan yang sama seperti run_cut_action/run_mix_action
## tapi memakai StoveTimingUI, bukan TypingManager.
func run_stove_timing_sequence() -> void:
	if stove_timing_ui == null:
		push_warning(
			"StoveTimingUI belum dipasang di " + command
			+ " -- fallback ke delay biasa (belum ada skill-check)."
		)
		finish_action_after_delay(1.0)
		return

	var prompts: Array = current_action_data.get(
		"prompts",
		["COOK"]
	)

	if camera_controller != null and interaction_camera_anchor != null:
		camera_controller.enter_interaction(interaction_camera_anchor)
		await camera_controller.transition_finished

	var results: Array = []

	for prompt in prompts:
		var result: String = await stove_timing_ui.run_timing(String(prompt))

		results.append(result)

		print(
			"[Workstation] ", command,
			" timing '", prompt, "' -> ", result
		)

	if camera_controller != null and interaction_camera_anchor != null:
		camera_controller.exit_interaction()
		await camera_controller.transition_finished

	last_timing_results = results

	timing_result.emit(self, current_action, results)

	complete_action()


func run_plate_action() -> void:


	finish_action_after_delay(0.5)


func run_serve_action() -> void:


	finish_action_after_delay(0.5)

func complete_action() -> void:
	if not action_in_progress:
		return

	var finished_action := current_action

	action_in_progress = false
	current_action = ""
	current_action_data = {}
	
	print(
		"[Workstation] ",
		command,
		" selesai action: ",
		finished_action
	)

	action_finished.emit(finished_action)

	action_completed.emit(
		self,
		finished_action
	)
func start_interaction() -> void:
	if is_interact:
		return
	is_interact = true
	print("Interaction " + command + " Dimulai")
	interaction_started.emit()

func finish_interaction() -> void:
	if not is_interact:
		return

	if current_action != "":
		return

	is_interact = false
	print("Interaction " + command + " Selesai") 
	interaction_finished.emit()

func finish_action_after_delay(duration: float) -> void:
	var timer := get_tree().create_timer(duration)
	timer.timeout.connect(complete_action)
