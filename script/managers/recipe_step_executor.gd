class_name RecipeStepExecutor
extends Node


signal step_completed
signal step_cancelled
var carried_item_id: String = ""

@export var player: Player
@export var typing_manager: TypingManager
@export var workstation_registry: WorkstationRegistry
@export var typing_ui: TypingUI

var current_step: Dictionary = {}

var current_recipe_name: String = ""

var current_workstation: Workstation = null

func set_recipe_name(recipe_name: String) -> void:
	current_recipe_name = recipe_name

	print(
		"[RecipeStepExecutor] Recipe aktif: ",
		current_recipe_name
	)
var pending_workstation: Workstation = null

var waiting_for_action: bool = false

func _ready() -> void:
	typing_manager.typing_completed.connect(_on_typing_completed)
	player.arrived_at_target.connect(_on_player_arrived)


func execute_step(step: Dictionary) -> void:
	current_step = step

	var workstation_name: String = step["workstation"]
	print(
	"[RecipeStepExecutor] Mencari workstation: ",
	workstation_name
)
	var workstation: Workstation = workstation_registry.get_workstation(workstation_name)

	if workstation == null:
		push_error("Workstation tidak ditemukan: " + workstation_name)
		return

	# R-P3-10 extension --- step TAKE di workstation ber-inventory (mis.
	# Kulkas) SKIP typing prompt tunggal biasa. Player sudah sampai di
	# workstation (MOVE step sebelumnya sudah selesai), jadi langsung
	# jalanin action-nya -- ItemPickManager yang nunjukkin semua nama
	# barang & nunggu ketikan player.
	var interaction_data: Dictionary = step.get("interaction", {})

	if step["type"] == RecipeData.StepType.ACTION \
		and step["action"] == RecipeData.ActionType.TAKE \
		and interaction_data.has("item_id"):
		run_action_step()
		return

	# R-P3-10 extension --- MOVE step yang datang dari prep item (dipicu
	# PrepLocationPicker, player udah "milih" lokasinya lewat prompt
	# lokasi kecil) SKIP typing prompt "KE TEMPAT ..." -- auto-jalan
	# langsung, biar gak double-ngetik buat 1 keputusan yang sama. MOVE
	# step di fase cooking TIDAK kena ini (skip_typing gak pernah diisi
	# di sana), jadi tetap kayak biasa.
	if step["type"] == RecipeData.StepType.MOVE \
	and step.get("skip_typing", false):
		start_move_step()
		return

	typing_ui.set_world_target(
		workstation.get_prompt_position()
	)

	typing_manager.call_deferred(
		"start_typing",
		String(step["prompt"])
	)


func _on_typing_completed(_command: String) -> void:
	if current_step.is_empty():
		return

	if waiting_for_action:
		return

	match current_step["type"]:
		RecipeData.StepType.MOVE:
			start_move_step()

		RecipeData.StepType.ACTION:
			run_action_step()

func start_move_step() -> void:
	var workstation_name: String = current_step["workstation"]

	var target_workstation: Workstation = (
		workstation_registry.get_workstation(workstation_name)
	)

	if target_workstation == null:
		push_error("Workstation tidak ditemukan: " + workstation_name)
		return

	if current_workstation != null:
		if current_workstation.action_completed.is_connected(_on_action_completed):
			current_workstation.action_completed.disconnect(_on_action_completed)
		current_workstation.finish_interaction()
		current_workstation = null

	pending_workstation = target_workstation

	player.move_to_target(
		target_workstation.get_navigation_position(),
		target_workstation.get_navigation_rotation()
	)


func _on_player_arrived() -> void:
	if current_step.is_empty():
		return

	if current_step.get("type") != RecipeData.StepType.MOVE:
		print(
			"[RecipeStepExecutor] Arrival diabaikan karena current step bukan MOVE: ",
			current_step.get("prompt", "")
		)
		return

	current_workstation = pending_workstation
	pending_workstation = null

	if not current_workstation.action_completed.is_connected(
		_on_action_completed
	):
		current_workstation.action_completed.connect(
			_on_action_completed
	)

	current_workstation.start_interaction()

	print(
		"[RecipeStepExecutor] MOVE selesai -> lanjut ke step berikutnya"
	)

	step_completed.emit()

func run_action_step() -> void:
	if current_workstation == null:
		push_error("Tidak ada workstation aktif.")
		return

	var required_workstation: String = current_step["workstation"]

	if current_workstation.command.to_upper() != required_workstation.to_upper():
		push_error(
			"Workstation salah. Dibutuhkan: " + required_workstation
		)
		return

	var action_value = current_step["action"]
	var action_name = RecipeData.ActionType.find_key(action_value)

	if action_name == null:
		push_error("Action tidak ditemukan.")
		return

	if waiting_for_action:
		push_warning("Masih menunggu action sebelumnya selesai.")
		return

	# ============================================================
	# VALIDASI ITEM UNTUK PLATING
	# ============================================================
	if action_value == RecipeData.ActionType.PLATE:
		var required_item_id: String = current_step.get(
			"interaction",
			{}
		).get("item_id", "")

		if not required_item_id.is_empty():
			if carried_item_id.is_empty():
				push_warning(
					"[RecipeStepExecutor] Tidak bisa PLATE. " +
					"Player belum membawa item."
				)
				return

			if carried_item_id != required_item_id:
				push_warning(
					"[RecipeStepExecutor] Item salah. " +
					"Dibawa: " + carried_item_id +
					" | Dibutuhkan: " + required_item_id
				)
				return

		var plating := current_workstation as Plating

		if plating == null:
			push_error("Workstation PLATING bukan instance Plating.")
			return

		if current_recipe_name.is_empty():
			push_error("Nama recipe belum diisi.")
			return

		if not plating.plate_recipe(current_recipe_name):
			return

	# ============================================================
	# ACTION NORMAL
	# ============================================================
	waiting_for_action = true

	print(
		"[RecipeStepExecutor] Memulai action: ",
		action_name
	)

	var interaction_data: Dictionary = current_step.get(
		"interaction",
		{}
	)

	current_workstation.perform_action(
		String(action_name),
		interaction_data
	)
func _on_action_completed(
	workstation: Workstation,
	action_name: String
) -> void:
	print("================================")
	print("[RSE] ACTION COMPLETED")
	print("[RSE] workstation =", workstation.command)
	print("[RSE] action =", action_name)
	print("[RSE] current_step =", current_step)
	print("[RSE] waiting_for_action =", waiting_for_action)
	print("================================")

	if not waiting_for_action:
		return

	if workstation != current_workstation:
		return

	waiting_for_action = false

	if action_name == "TAKE":

		var picked_item_id: String = workstation.current_picked_item_id

		if picked_item_id.is_empty():

			print(
				"[RecipeStepExecutor] TAKE dibatalkan. "
				+ "Tidak ada item yang diambil."
			)

			current_step.clear()
			pending_workstation = null

			if current_workstation != null:
				if current_workstation.action_completed.is_connected(
					_on_action_completed
				):
					current_workstation.action_completed.disconnect(
						_on_action_completed
					)

				current_workstation.finish_interaction()
				current_workstation = null

			step_cancelled.emit()
			return

		carried_item_id = picked_item_id

		print(
			"[RecipeStepExecutor] Player membawa: ",
			carried_item_id
		)
		print(
			"[RecipeStepExecutor] Player membawa: ",
			carried_item_id
		)

	elif action_name == "PLATE":

		print(
			"[RecipeStepExecutor] Item diserahkan: ",
			carried_item_id
		)

		carried_item_id = ""

	print(
		"[RecipeStepExecutor] Action selesai: ",
		action_name
	)

	step_completed.emit()
func cancel_current_step() -> void:
	print("================================")
	print("[RSE] CANCEL CURRENT STEP")
	print("[RSE] current_step =", current_step)
	print("[RSE] current_workstation =", current_workstation)
	print("================================")

	# Hentikan movement lama
	if player != null:
		player.is_moving = false
		player.velocity = Vector3.ZERO

	# Paksa TypingUI hilang sekarang juga
	if typing_ui != null:
		typing_ui.cancel()

	# Batalkan action yang masih hidup di workstation
	if current_workstation != null:
		current_workstation.cancel_current_action()

		if current_workstation.action_completed.is_connected(
			_on_action_completed
		):
			current_workstation.action_completed.disconnect(
				_on_action_completed
			)

	# Reset state RSE
	current_step.clear()
	waiting_for_action = false
	pending_workstation = null
	current_workstation = null
	carried_item_id = ""

	print("[RSE] Current step berhasil dibatalkan.")
