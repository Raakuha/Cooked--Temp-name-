extends RefCounted
class_name RecipeData

# Workstation command IDs.
# Nilai ini harus sama dengan `command` pada masing-masing node Workstation.
const WS_REFRIGERATOR := "REFRIGERATOR"
const WS_RICE_STORAGE := "RICE_STORAGE"
const WS_BUN_STORAGE := "BUN_STORAGE"
const WS_PRODUCE := "PRODUCE"
const WS_SEASONING := "SEASONING"
const WS_STOVE := "STOVE"                 # Wok / kompor untuk nasgor
const WS_FLAT_PAN := "FLAT_PAN"           # Wajan datar untuk steak & burger
const WS_CUTTING_BOARD := "CUTTING_BOARD"
const WS_OVEN := "OVEN"


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


# `interaction` bersifat opsional.
# Dipakai untuk sub-prompt aktif di dalam action seperti MIX / CUT / COOK.
# RecipeStepExecutor / Workstation nanti cukup membaca data ini tanpa
# meng-hardcode prompt per menu di Workstation.gd.
const RECIPES = {
	# ================================================================
	# NASGOR GORENG
	# Alur: nasi -> daging -> telur -> bumbu -> wok -> plating
	# ================================================================
	"nasgor_goreng": [
		{
			"type": StepType.MOVE,
			"workstation": WS_RICE_STORAGE,
			"prompt": "KE TEMPAT NASI",
			"action": ActionType.NONE
		},
		{
			"type": StepType.ACTION,
			"workstation": WS_RICE_STORAGE,
			"prompt": "AMBIL NASI",
			"action": ActionType.TAKE
		},
		{
			"type": StepType.MOVE,
			"workstation": WS_REFRIGERATOR,
			"prompt": "KE KULKAS",
			"action": ActionType.NONE
		},
		{
			"type": StepType.ACTION,
			"workstation": WS_REFRIGERATOR,
			"prompt": "AMBIL DAGING CINCANG",
			"action": ActionType.TAKE
		},
		{
			"type": StepType.MOVE,
			"workstation": WS_PRODUCE,
			"prompt": "KE TEMPAT TELUR",
			"action": ActionType.NONE
		},
		{
			"type": StepType.ACTION,
			"workstation": WS_PRODUCE,
			"prompt": "AMBIL TELUR",
			"action": ActionType.TAKE
		},
		{
			"type": StepType.MOVE,
			"workstation": WS_SEASONING,
			"prompt": "KE TEMPAT BUMBU",
			"action": ActionType.NONE
		},
		{
			"type": StepType.ACTION,
			"workstation": WS_SEASONING,
			"prompt": "AMBIL BUMBU",
			"action": ActionType.TAKE
		},
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
			"action": ActionType.OPEN
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
			"type": StepType.ACTION,
			"workstation": WS_STOVE,
			"prompt": "PLATING NASI GORENG",
			"action": ActionType.PLATE
		}
	],

	# ================================================================
	# STEAK
	# Alur: butter -> wagyu -> bumbu -> wajan datar -> plating
	# ================================================================
	"steak": [
		{
			"type": StepType.MOVE,
			"workstation": WS_REFRIGERATOR,
			"prompt": "KE KULKAS",
			"action": ActionType.NONE
		},
		{
			"type": StepType.ACTION,
			"workstation": WS_REFRIGERATOR,
			"prompt": "AMBIL BUTTER",
			"action": ActionType.TAKE
		},
		{
			"type": StepType.ACTION,
			"workstation": WS_REFRIGERATOR,
			"prompt": "AMBIL DAGING WAGYU",
			"action": ActionType.TAKE
		},
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
			"type": StepType.ACTION,
			"workstation": WS_FLAT_PAN,
			"prompt": "PLATING STEAK",
			"action": ActionType.PLATE
		}
	],

	# ================================================================
	# SALAD
	# Alur: buah & sayur -> bumbu -> talenan -> plating
	# ================================================================
	"salad": [
		{
			"type": StepType.MOVE,
			"workstation": WS_PRODUCE,
			"prompt": "KE TEMPAT BUAH DAN SAYUR",
			"action": ActionType.NONE
		},
		{
			"type": StepType.ACTION,
			"workstation": WS_PRODUCE,
			"prompt": "AMBIL BUAH DAN SAYUR",
			"action": ActionType.TAKE
		},
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
			"type": StepType.ACTION,
			"workstation": WS_CUTTING_BOARD,
			"prompt": "PLATING SALAD",
			"action": ActionType.PLATE
		}
	],

	# ================================================================
	# ROTI KHAS LEMPUYANGAN ISI DAGING
	# Alur: adonan -> daging -> talenan -> oven -> plating
	# Adonan dan daging sama-sama diambil dari kulkas sesuai keputusan terbaru.
	# ================================================================
	"roti_khas_lempuyangan": [
		{
			"type": StepType.MOVE,
			"workstation": WS_REFRIGERATOR,
			"prompt": "KE KULKAS",
			"action": ActionType.NONE
		},
		{
			"type": StepType.ACTION,
			"workstation": WS_REFRIGERATOR,
			"prompt": "AMBIL ADONAN",
			"action": ActionType.TAKE
		},
		{
			"type": StepType.ACTION,
			"workstation": WS_REFRIGERATOR,
			"prompt": "AMBIL DAGING",
			"action": ActionType.TAKE
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
			"type": StepType.ACTION,
			"workstation": WS_OVEN,
			"prompt": "PLATING ROTI",
			"action": ActionType.PLATE
		}
	],

	# ================================================================
	# BURGER BANGGOR
	# Alur: bun -> patty -> bumbu -> wajan datar -> plating
	# ================================================================
	"burger_banggor": [
		{
			"type": StepType.MOVE,
			"workstation": WS_BUN_STORAGE,
			"prompt": "KE TEMPAT BUN",
			"action": ActionType.NONE
		},
		{
			"type": StepType.ACTION,
			"workstation": WS_BUN_STORAGE,
			"prompt": "AMBIL BUN BURGER",
			"action": ActionType.TAKE
		},
		{
			"type": StepType.MOVE,
			"workstation": WS_REFRIGERATOR,
			"prompt": "KE KULKAS",
			"action": ActionType.NONE
		},
		{
			"type": StepType.ACTION,
			"workstation": WS_REFRIGERATOR,
			"prompt": "AMBIL PATTY",
			"action": ActionType.TAKE
		},
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
			"type": StepType.ACTION,
			"workstation": WS_FLAT_PAN,
			"prompt": "PLATING BURGER",
			"action": ActionType.PLATE
		}
	],

	# ================================================================
	# AIR MINERAL
	# Alur: kulkas -> ambil minuman -> selesai
	# ================================================================
	"air_mineral": [
		{
			"type": StepType.MOVE,
			"workstation": WS_REFRIGERATOR,
			"prompt": "KE KULKAS",
			"action": ActionType.NONE
		},
		{
			"type": StepType.ACTION,
			"workstation": WS_REFRIGERATOR,
			"prompt": "AMBIL AIR MINERAL",
			"action": ActionType.TAKE
		}
	],

	# ================================================================
	# SODA
	# Alur: kulkas -> ambil minuman -> selesai
	# ================================================================
	"soda": [
		{
			"type": StepType.MOVE,
			"workstation": WS_REFRIGERATOR,
			"prompt": "KE KULKAS",
			"action": ActionType.NONE
		},
		{
			"type": StepType.ACTION,
			"workstation": WS_REFRIGERATOR,
			"prompt": "AMBIL SODA",
			"action": ActionType.TAKE
		}
	]
}
