extends RefCounted
class_name RecipeData

# Workstation command IDs.
# Sesuaikan string di bawah dengan `command` pada node Workstation masing-masing.
const WS_REFRIGERATOR := "REFRIGERATOR"
const WS_RICE_STORAGE := "RICE_STORAGE"
const WS_BUN_STORAGE := "BUN_STORAGE"
const WS_PRODUCE := "PRODUCE"
const WS_SEASONING := "SEASONING"
const WS_STOVE := "STOVE"
const WS_FLAT_PAN := "FLAT_PAN"
const WS_CUTTING_BOARD := "CUTTING_BOARD"
const WS_OVEN := "OVEN"
const WS_PLATING := "PLATING"

enum StepType {
	MOVE,
	ACTION
}

enum ActionType {
	NONE,
	OPEN,
	CLOSE,
	TAKE,
	ADD,
	CUT,
	MIX,
	COOK,
	FRY,
	PLATE,
	SERVE
}

# R-P3-11 --- Opsional: override deadline (detik) per recipe_id.
# Kalau recipe_id tidak ada di sini, MenuDeadlineTimer pakai
# default_deadline_seconds. Isi/sesuaikan angkanya sesuai kebutuhan balance.
const DEADLINES: Dictionary = {
	 "nasgor_goreng": 90.0,
	# "steak": 120.0,
}

# ====================================================================
# R-P3-10 --- Recipe Checklist / Semi-linear Preparation
#
# Tiap recipe sekarang Dictionary dengan 2 bagian:
#
#   "prep"    -> Array of prep item. Tiap item:
#                { "checklist_id": String, "steps": Array of step }
#                Prep item BEBAS dikerjakan urutan apa saja (lihat
#                CookingSequenceManager.start_prep_item()).
#
#   "cooking" -> Array of step, URUT kayak dulu (heat -> add -> mix ->
#                plate). Baru mulai jalan setelah SEMUA prep item selesai.
#
# Aturan pemisahannya: semua step TAKE di awal resep = prep (checklist,
# bebas urutan). Begitu ketemu action pertama yang bukan TAKE (ADD/CUT/
# COOK/dst), itu masuk cooking (tetap terurut). Resep minuman (gak ada
# proses masak) punya "cooking": [] -- kosong, itu normal.
#
# `interaction.prompts` opsional untuk action yang punya rangkaian typing.
# ====================================================================
const RECIPES = {

	# ================================================================
	# NASI GORENG
	# ================================================================
	"nasgor_goreng": {
		"prep": [
			{
				"checklist_id": "nasi",
				"steps": [
					{
						"type": StepType.MOVE,
						"skip_typing": true,
						"workstation": WS_RICE_STORAGE,
						"prompt": "KE TEMPAT NASI",
						"action": ActionType.NONE
					},
					{
						"type": StepType.ACTION,
						"workstation": WS_RICE_STORAGE,
						"prompt": "AMBIL NASI",
						"action": ActionType.TAKE,
						"interaction": {"item_id": "nasi"}
					}
				]
			},
			{
				"checklist_id": "daging",
				"steps": [
					{
						"type": StepType.MOVE,
						"skip_typing": true,
						"workstation": WS_REFRIGERATOR,
						"prompt": "KE KULKAS",
						"action": ActionType.NONE
					},
					{
						"type": StepType.ACTION,
						"workstation": WS_REFRIGERATOR,
						"prompt": "AMBIL DAGING CINCANG",
						"action": ActionType.TAKE,
						"interaction": {"item_id": "daging_cincang"}
					}
				]
			},
			{
				"checklist_id": "telur",
				"steps": [
					{
						"type": StepType.MOVE,
						"skip_typing": true,
						"workstation": WS_REFRIGERATOR,
						"prompt": "KE KULKAS",
						"action": ActionType.COOK
					},
					{
						"type": StepType.ACTION,
						"workstation": WS_REFRIGERATOR,
						"prompt": "AMBIL TELUR",
						"action": ActionType.TAKE,
						"interaction": {"item_id": "telur"}
					}
				]
			},
			{
				"checklist_id": "bumbu",
				"steps": [
					{
						"type": StepType.MOVE,
						"skip_typing": true,
						"workstation": WS_SEASONING,
						"prompt": "KE TEMPAT BUMBU",
						"action": ActionType.NONE
					},
					{
						"type": StepType.ACTION,
						"workstation": WS_SEASONING,
						"prompt": "AMBIL BUMBU",
						"action": ActionType.TAKE,
						"interaction": {"item_id": "bumbu"}
					}
				]
			}
		],
		"cooking": [
			{
				"type": StepType.MOVE,
				"workstation": WS_STOVE,
				"prompt": "KE WOK",
				"action": ActionType.NONE
			},
			{
				"type": StepType.ACTION,
				"workstation": WS_STOVE,
				"prompt": "PANASKAN MINYAK",
				"action": ActionType.COOK
			},
			{
				"type": StepType.ACTION,
				"workstation": WS_STOVE,
				"prompt": "MASUKKAN BUMBU",
				"action": ActionType.ADD
			},
			{
				"type": StepType.ACTION,
				"workstation": WS_STOVE,
				"prompt": "MASUKKAN TELUR",
				"action": ActionType.ADD
			},
			{
				"type": StepType.ACTION,
				"workstation": WS_STOVE,
				"prompt": "MASUKKAN DAGING CINCANG",
				"action": ActionType.ADD
			},
			{
				"type": StepType.ACTION,
				"workstation": WS_STOVE,
				"prompt": "MASUKKAN NASI",
				"action": ActionType.ADD
			},
			{
				"type": StepType.ACTION,
				"workstation": WS_STOVE,
				"prompt": "ADUK NASI GORENG",
				"action": ActionType.MIX,
				"interaction": {
					"prompts": ["MIX", "MIX", "MIX"]
				}
			},
			{
				"type": StepType.MOVE,
				"workstation": WS_PLATING,
				"prompt": "KE TEMPAT PLATING",
				"action": ActionType.NONE
			},
			{
				"type": StepType.ACTION,
				"workstation": WS_PLATING,
				"prompt": "PLATING NASI GORENG",
				"action": ActionType.PLATE
			}
		]
	},

	# ================================================================
	# STEAK
	# ================================================================
	"steak": {
		"prep": [
			{
				"checklist_id": "butter",
				"steps": [
					{
						"type": StepType.MOVE,
						"skip_typing": true,
						"workstation": WS_REFRIGERATOR,
						"prompt": "KE KULKAS",
						"action": ActionType.NONE
					},
					{
						"type": StepType.ACTION,
						"workstation": WS_REFRIGERATOR,
						"prompt": "AMBIL BUTTER",
						"action": ActionType.TAKE,
						"interaction": {"item_id": "butter"}
					}
				]
			},
			{
				"checklist_id": "daging_wagyu",
				"steps": [
					{
						"type": StepType.MOVE,
						"skip_typing": true,
						"workstation": WS_REFRIGERATOR,
						"prompt": "KE KULKAS",
						"action": ActionType.NONE
					},
					{
						"type": StepType.ACTION,
						"workstation": WS_REFRIGERATOR,
						"prompt": "AMBIL DAGING WAGYU",
						"action": ActionType.TAKE,
						"interaction": {"item_id": "daging_wagyu"}
					}
				]
			}
		],
		"cooking": [
			{
				"type": StepType.MOVE,
				"workstation": WS_SEASONING,
				"prompt": "KE TEMPAT BUMBU",
				"action": ActionType.NONE
			},
			{
				"type": StepType.ACTION,
				"workstation": WS_SEASONING,
				"prompt": "BUMBUHI DAGING",
				"action": ActionType.ADD
			},
			{
				"type": StepType.MOVE,
				"workstation": WS_FLAT_PAN,
				"prompt": "KE WAJAN DATAR",
				"action": ActionType.NONE
			},
			{
				"type": StepType.ACTION,
				"workstation": WS_FLAT_PAN,
				"prompt": "MASAK STEAK",
				"action": ActionType.COOK,
				"interaction": {
					"prompts": ["MASAK", "BALIK", "MASAK", "BALIK", "ANGKAT"]
				}
			},
			{
				"type": StepType.MOVE,
				"workstation": WS_PLATING,
				"prompt": "KE TEMPAT PLATING",
				"action": ActionType.NONE
			},
			{
				"type": StepType.ACTION,
				"workstation": WS_PLATING,
				"prompt": "PLATING STEAK",
				"action": ActionType.PLATE
			}
		]
	},

	# ================================================================
	# SALAD
	# ================================================================
	"salad": {
		"prep": [
			{
				"checklist_id": "buah",
				"steps": [
					{
						"type": StepType.MOVE,
						"skip_typing": true,
						"workstation": WS_PRODUCE,
						"prompt": "KE TEMPAT BUAH DAN SAYUR",
						"action": ActionType.NONE
					},
					{
						"type": StepType.ACTION,
						"workstation": WS_PRODUCE,
						"prompt": "AMBIL BUAH",
						"action": ActionType.TAKE,
						"interaction": {"item_id": "buah"}
					}
				]
			},
			{
				"checklist_id": "sayur",
				"steps": [
					{
						"type": StepType.MOVE,
						"skip_typing": true,
						"workstation": WS_PRODUCE,
						"prompt": "KE TEMPAT BUAH DAN SAYUR",
						"action": ActionType.NONE
					},
					{
						"type": StepType.ACTION,
						"workstation": WS_PRODUCE,
						"prompt": "AMBIL SAYUR",
						"action": ActionType.TAKE,
						"interaction": {"item_id": "sayur"}
					}
				]
			}
		],
		"cooking": [
			{
				"type": StepType.MOVE,
				"workstation": WS_SEASONING,
				"prompt": "KE TEMPAT BUMBU",
				"action": ActionType.NONE
			},
			{
				"type": StepType.ACTION,
				"workstation": WS_SEASONING,
				"prompt": "BUMBUHI SALAD",
				"action": ActionType.ADD
			},
			{
				"type": StepType.MOVE,
				"workstation": WS_CUTTING_BOARD,
				"prompt": "KE TALENAN",
				"action": ActionType.NONE
			},
			{
				"type": StepType.ACTION,
				"workstation": WS_CUTTING_BOARD,
				"prompt": "POTONG BAHAN SALAD",
				"action": ActionType.CUT,
				"interaction": {
					"prompts": ["POTONG", "POTONG", "CINCANG", "POTONG", "RAPIKAN"]
				}
			},
			{
				"type": StepType.MOVE,
				"workstation": WS_PLATING,
				"prompt": "KE TEMPAT PLATING",
				"action": ActionType.NONE
			},
			{
				"type": StepType.ACTION,
				"workstation": WS_PLATING,
				"prompt": "PLATING SALAD",
				"action": ActionType.PLATE
			}
		]
	},

	# ================================================================
	# ROTI KHAS LEMPUYANGAN ISI DAGING
	# ================================================================
	"roti_khas_lempuyangan": {
		"prep": [
			{
				"checklist_id": "adonan",
				"steps": [
					{
						"type": StepType.MOVE,
						"skip_typing": true,
						"workstation": WS_REFRIGERATOR,
						"prompt": "KE KULKAS",
						"action": ActionType.NONE
					},
					{
						"type": StepType.ACTION,
						"workstation": WS_REFRIGERATOR,
						"prompt": "AMBIL ADONAN",
						"action": ActionType.TAKE,
						"interaction": {"item_id": "adonan"}
					}
				]
			},
			{
				"checklist_id": "daging",
				"steps": [
					{
						"type": StepType.MOVE,
						"skip_typing": true,
						"workstation": WS_REFRIGERATOR,
						"prompt": "KE KULKAS",
						"action": ActionType.NONE
					},
					{
						"type": StepType.ACTION,
						"workstation": WS_REFRIGERATOR,
						"prompt": "AMBIL DAGING",
						"action": ActionType.TAKE,
						"interaction": {"item_id": "daging"}
					}
				]
			}
		],
		"cooking": [
			{
				"type": StepType.MOVE,
				"workstation": WS_CUTTING_BOARD,
				"prompt": "KE TALENAN",
				"action": ActionType.NONE
			},
			{
				"type": StepType.ACTION,
				"workstation": WS_CUTTING_BOARD,
				"prompt": "OLAH ADONAN DAN DAGING",
				"action": ActionType.CUT,
				"interaction": {
					"prompts": ["TEKAN", "ISI", "BENTUK"]
				}
			},
			{
				"type": StepType.MOVE,
				"workstation": WS_OVEN,
				"prompt": "KE OVEN",
				"action": ActionType.NONE
			},
			{
				"type": StepType.ACTION,
				"workstation": WS_OVEN,
				"prompt": "PANGGANG ROTI",
				"action": ActionType.COOK,
				"interaction": {
					"prompts": ["PANGGANG", "BALIK", "PANGGANG"]
				}
			},
			{
				"type": StepType.MOVE,
				"workstation": WS_PLATING,
				"prompt": "KE TEMPAT PLATING",
				"action": ActionType.NONE
			},
			{
				"type": StepType.ACTION,
				"workstation": WS_PLATING,
				"prompt": "PLATING ROTI",
				"action": ActionType.PLATE
			}
		]
	},

	# ================================================================
	# BURGER BANGGOR
	# ================================================================
	"burger_banggor": {
		"prep": [
			{
				"checklist_id": "bun",
				"steps": [
					{
						"type": StepType.MOVE,
						"skip_typing": true,
						"workstation": WS_BUN_STORAGE,
						"prompt": "KE TEMPAT BUN",
						"action": ActionType.NONE
					},
					{
						"type": StepType.ACTION,
						"workstation": WS_BUN_STORAGE,
						"prompt": "AMBIL BUN BURGER",
						"action": ActionType.TAKE,
						"interaction": {"item_id": "bun_burger"}
					}
				]
			},
			{
				"checklist_id": "patty",
				"steps": [
					{
						"type": StepType.MOVE,
						"skip_typing": true,
						"workstation": WS_REFRIGERATOR,
						"prompt": "KE KULKAS",
						"action": ActionType.NONE
					},
					{
						"type": StepType.ACTION,
						"workstation": WS_REFRIGERATOR,
						"prompt": "AMBIL PATTY",
						"action": ActionType.TAKE,
						"interaction": {"item_id": "patty"}
					}
				]
			}
		],
		"cooking": [
			{
				"type": StepType.MOVE,
				"workstation": WS_SEASONING,
				"prompt": "KE TEMPAT BUMBU",
				"action": ActionType.NONE
			},
			{
				"type": StepType.ACTION,
				"workstation": WS_SEASONING,
				"prompt": "BUMBUHI PATTY",
				"action": ActionType.ADD
			},
			{
				"type": StepType.MOVE,
				"workstation": WS_FLAT_PAN,
				"prompt": "KE WAJAN DATAR",
				"action": ActionType.NONE
			},
			{
				"type": StepType.ACTION,
				"workstation": WS_FLAT_PAN,
				"prompt": "MASAK BURGER",
				"action": ActionType.COOK,
				"interaction": {
					"prompts": ["MASAK", "BALIK", "MASAK", "BALIK", "ANGKAT"]
				}
			},
			{
				"type": StepType.MOVE,
				"workstation": WS_PLATING,
				"prompt": "KE TEMPAT PLATING",
				"action": ActionType.NONE
			},
			{
				"type": StepType.ACTION,
				"workstation": WS_PLATING,
				"prompt": "PLATING BURGER",
				"action": ActionType.PLATE
			}
		]
	},

	# ================================================================
	# AIR MINERAL
	# Minuman: cuma prep, gak ada fase cooking sama sekali.
	# ================================================================
	"air_mineral": {
		"prep": [
			{
				"checklist_id": "air_mineral",
				"steps": [
					{
						"type": StepType.MOVE,
						"skip_typing": true,
						"workstation": WS_REFRIGERATOR,
						"prompt": "KE KULKAS",
						"action": ActionType.NONE
					},
					{
						"type": StepType.ACTION,
						"workstation": WS_REFRIGERATOR,
						"prompt": "AMBIL AIR MINERAL",
						"action": ActionType.TAKE,
						"interaction": {"item_id": "air_mineral"}
					}
				]
			}
		],
		"cooking": []
	},

	# ================================================================
	# SODA
	# ================================================================
	"soda": {
		"prep": [
			{
				"checklist_id": "soda",
				"steps": [
					{
						"type": StepType.MOVE,
						"skip_typing": true,
						"workstation": WS_REFRIGERATOR,
						"prompt": "KE KULKAS",
						"action": ActionType.NONE
					},
					{
						"type": StepType.ACTION,
						"workstation": WS_REFRIGERATOR,
						"prompt": "AMBIL SODA",
						"action": ActionType.TAKE,
						"interaction": {"item_id": "soda"}
					}
				]
			}
		],
		"cooking": []
	}
}
