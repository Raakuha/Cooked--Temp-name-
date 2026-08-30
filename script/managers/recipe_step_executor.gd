class_name RecipeStepExecutor
extends Node


signal step_completed
signal step_cancelled
var food_pickup_in_progress: bool = false
signal food_carry_ready

var carried_item_id: String = ""
var carried_food: Node3D = null

const FOOD_SCENES: Dictionary = {
	"steak": "res://assets/Makanan_Utama/Steak.glb",
	"burger_banggor": "res://assets/Makanan_Utama/BurgerBangor.glb",
	"nasgor_goreng": "res://assets/Makanan_Utama/NasgorGoreng.glb",
	"roti_khas_lempuyangan": "res://assets/Makanan_Utama/RotiLempuyungan.glb",
	"salad": "res://assets/Makanan_Utama/Salad.glb",
	"soda": "res://assets/Makanan_Utama/Soda.glb",
	"air_mineral": "res://assets/Makanan_Utama/AirMineral.glb"
	
}

const FOOD_SCALES: Dictionary = {
	"steak": 8.0,
	"burger_banggor": 10.0,
	"roti_khas_lempuyangan": 8.0,
	"salad": 7.0,
	"soda": 10.0,
	"air_mineral": 10.0,
	"nasgor_goreng": 9.0
}
@export var food_attachment: BoneAttachment3D
@export var player: Player
@export var typing_manager: TypingManager
@export var workstation_registry: WorkstationRegistry
@export var typing_ui: TypingUI
@export var cooking_sequence_manager: CookingSequenceManager

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

	if cooking_sequence_manager != null:
		cooking_sequence_manager.food_ready_to_carry.connect(
			_on_food_ready_to_carry
		)
func _on_food_ready_to_carry(recipe_id: String) -> void:
	if recipe_id != current_recipe_name:
		return

	food_pickup_in_progress = true

	print(
		"[RSE] FOOD READY -> mulai AmbilNampan: ",
		current_recipe_name
	)

	# Makanan muncul bersamaan dengan awal animasi AmbilNampan.
	spawn_carried_food()

	if player == null:
		food_pickup_in_progress = false
		food_carry_ready.emit()
		return

	player.is_carrying_tray = false

	await player.play_tray_pickup_animation()

	player.is_carrying_tray = true
	food_pickup_in_progress = false

	print("[RSE] AmbilNampan selesai -> siap dibawa.")

	food_carry_ready.emit()
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
	if (
	step["type"] == RecipeData.StepType.MOVE
	and step["workstation"] == RecipeData.WS_PLATING
	and food_pickup_in_progress
	):
		print("[RSE] Menunggu AmbilNampan selesai sebelum MOVE PLATING.")

		await food_carry_ready

		print("[RSE] Food sudah siap dibawa -> lanjut MOVE PLATING.")
	
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
		clear_carried_food()

		if player != null:
			player.is_carrying_tray = false
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
	
func spawn_carried_food() -> void:
	# Jangan spawn dua kali.
	if carried_food != null:
		carried_food.queue_free()
		carried_food = null

	if food_attachment == null:
		push_warning(
			"[RSE] FoodAttachment belum dipasang."
		)
		return

	if current_recipe_name.is_empty():
		push_warning(
			"[RSE] current_recipe_name kosong."
		)
		return

	var food_path: String = FOOD_SCENES.get(
		current_recipe_name,
		""
	)

	if food_path.is_empty():
		push_warning(
			"[RSE] Tidak ada food scene untuk recipe: "
			+ current_recipe_name
		)
		return

	var food_scene_resource: Resource = load(food_path)

	if food_scene_resource == null:
		push_error(
			"[RSE] Gagal load food scene: "
			+ food_path
		)
		return

	if not food_scene_resource is PackedScene:
		push_error(
			"[RSE] Resource bukan PackedScene: "
			+ food_path
		)
		return

	carried_food = (
		food_scene_resource as PackedScene
	).instantiate() as Node3D

	if carried_food == null:
		push_error(
			"[RSE] Gagal instantiate food: "
			+ food_path
		)
		return
	food_attachment.add_child(carried_food)
	carried_food.position = Vector3.ZERO
	carried_food.rotation_degrees = Vector3(
		45.0,
		0.0,
		30.0
	)
	var food_scale: float = FOOD_SCALES.get(
		current_recipe_name,
		1.0
	)
	carried_food.scale = Vector3(
		food_scale,
		food_scale,
		food_scale
	)
	carried_food.position = Vector3(
	0.05,
	0.75,
	0.03
	)
	
	print(
	"[RSE] FOOD SPAWNED: ",
	carried_food.name,
	" | parent = ",
	carried_food.get_parent().name,
	" | global_position = ",
	carried_food.global_position
	)	
	print("[RSE] Food scale = ", carried_food.scale)
	print("[RSE] Food visible = ", carried_food.visible)
	print("[RSE] Food child count = ", carried_food.get_child_count())

	for child in carried_food.get_children():
		print(
			"[RSE] CHILD ",
			child.name,
			" | class = ",
			child.get_class()
		)

		if child.get_class() == "MeshInstance3D":
			var mesh_instance: MeshInstance3D = child as MeshInstance3D

			if mesh_instance == null:
				print("[RSE] GAGAL CAST: ", child.name)
				continue

			print(
				"[RSE] MESH ",
				mesh_instance.name,
				" | visible = ",
				mesh_instance.visible,
				" | position = ",
				mesh_instance.position,
				" | rotation = ",
				mesh_instance.rotation,
				" | scale = ",
				mesh_instance.scale,
				" | mesh = ",
				mesh_instance.mesh
			)

			if mesh_instance.mesh != null:
				print(
					"[RSE] AABB ",
					mesh_instance.name,
					" = ",
					mesh_instance.get_aabb().size
				)
func clear_carried_food() -> void:
	if carried_food == null:
		return

	carried_food.queue_free()
	carried_food = null
