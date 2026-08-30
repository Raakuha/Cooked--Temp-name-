extends RefCounted
class_name RecipeData


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
	PLATE,
	SERVE
}


const DEADLINES: Dictionary = {
	 "nasgor_goreng": 65.0,
	 "steak": 65.0,
	 "salad": 45.0,
	"roti_khas_lempuyangan": 60.0,
	"soda" : 20.0,
	"air_mineral" : 20.0,
	"burger_banggor" : 65.0
}

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
						"prompt": "BASKOM NASI BEKAS",
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
				"checklist_id": "daging_cincang",
				"steps": [
					{
						"type": StepType.MOVE,
						"skip_typing": true,
						"workstation": WS_REFRIGERATOR,
						"prompt": "KULKAS",
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
						"prompt": "KULKAS",
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
						"prompt": "TEMPAT BUMBU",
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
				"prompt": "WOK",
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
					"prompts": ["SRENG", "SRONG", "SRENG", "ANGKAT"]
				}
			},
			{
				"type": StepType.MOVE,
				"workstation": WS_PLATING,
				"prompt": "PLATING",
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
						"prompt": "KULKAS",
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
						"prompt": "KULKAS",
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
				"workstation": WS_CUTTING_BOARD,
				"prompt": "TALENAN",
				"action": ActionType.NONE
			},
			{
				"type": StepType.ACTION,
				"workstation": WS_CUTTING_BOARD,
				"prompt": "POTONG DAGING",
				"action": ActionType.CUT
			},
			{
				"type": StepType.MOVE,
				"workstation": WS_FLAT_PAN,
				"prompt": "WAJAN DATAR",
				"action": ActionType.NONE
			},
			{
				"type": StepType.ACTION,
				"workstation" : WS_FLAT_PAN,
				"prompt" : "ATUR SUHU KOMPOR",
				"action" : ActionType.COOK
			},
			{
				"type": StepType.ACTION,
				"workstation" : WS_FLAT_PAN,
				"prompt" : "MASUKKAN MENTEGA",
				"action" : ActionType.ADD
			},
			{
				"type": StepType.ACTION,
				"workstation": WS_FLAT_PAN,
				"prompt": "MASAK STEAK",
				"action": ActionType.MIX,
				"interaction": {
					"prompts": ["TEKAN", "BALIK", "TEKAN","BALIK", "ANGKAT"]
				}
			},
			{
				"type": StepType.MOVE,
				"workstation": WS_PLATING,
				"prompt": "PLATING",
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
						"prompt": "TEMPAT BUAH DAN SAYUR",
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
						"prompt": "TEMPAT BUAH DAN SAYUR",
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
				"workstation": WS_CUTTING_BOARD,
				"prompt": "TALENAN",
				"action": ActionType.NONE
			},
			{
				"type": StepType.ACTION,
				"workstation": WS_CUTTING_BOARD,
				"prompt": "POTONG BUAH DAN SAYUR",
				"action": ActionType.CUT,
				"interaction": {
					"prompts": ["POTONG", "POTONG", "CINCANG", "POTONG", "RAPIKAN"]
				}
			},
			{
				"type": StepType.MOVE,
				"workstation": WS_SEASONING,
				"prompt": "TEMPAT BUMBU",
				"action": ActionType.NONE
			},
			{
				"type": StepType.ACTION,
				"workstation": WS_SEASONING,
				"prompt": "DRESSING SALAD",
				"action": ActionType.ADD
			},
			{
				"type": StepType.MOVE,
				"workstation": WS_PLATING,
				"prompt": "PLATING",
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
						"prompt": "KULKAS",
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
						"prompt": "KULKAS",
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
				"prompt": "TALENAN",
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
				"prompt": "OVEN",
				"action": ActionType.NONE
			},
			{
				"type": StepType.ACTION,
				"workstation": WS_OVEN,
				"prompt": "PANGGANG ROTI",
				"action": ActionType.COOK,
				"interaction": {
					"prompts": ["PANGGANG"]
				}
			},
			{
				"type": StepType.MOVE,
				"workstation": WS_PLATING,
				"prompt": "PLATING",
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
						"prompt": "TEMPAT BUN",
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
						"prompt": "KULKAS",
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
			},
			{
				"checklist_id": "mentega",
				"steps": [
					{
						"type": StepType.MOVE,
						"skip_typing": true,
						"workstation": WS_REFRIGERATOR,
						"prompt": "KULKAS",
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
			}
		],
		"cooking": [
			{
				"type": StepType.MOVE,
				"workstation": WS_SEASONING,
				"prompt": "TEMPAT BUMBU",
				"action": ActionType.NONE
			},
			{
				"type": StepType.ACTION,
				"workstation": WS_SEASONING,
				"prompt": "OLESKAN BUTTER DI ROTI",
				"action": ActionType.ADD
			},
			{
				"type": StepType.MOVE,
				"workstation": WS_FLAT_PAN,
				"prompt": "WAJAN DATAR",
				"action": ActionType.NONE
			},
			{
				"type": StepType.ACTION,
				"workstation": WS_FLAT_PAN,
				"prompt": "MASAK BURGER",
				"action": ActionType.MIX,
				"interaction": {
					"prompts": ["MASAK", "BALIK", "MASAK", "BALIK", "ANGKAT"]
				}
			},
			{
				"type": StepType.MOVE,
				"workstation": WS_PLATING,
				"prompt": "PLATING",
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
						"prompt": "KULKAS",
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
		"cooking": [
					{
						"type": StepType.MOVE,
						"workstation": WS_PLATING,
						"prompt": "SERAHKAN KE PELANGGAN",
						"action": ActionType.NONE
					},
					{
						"type": StepType.ACTION,
						"workstation": WS_PLATING,
						"prompt": "BERIKAN AIR MINERAL",
						"action": ActionType.PLATE,
						"interaction": {"item_id": "air_mineral"}
					}
		]
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
						"prompt": "KULKAS",
						"action": ActionType.NONE
					},
					{
						"type": StepType.ACTION,
						"workstation": WS_REFRIGERATOR,
						"prompt": "AMBIL SODA",
						"action": ActionType.TAKE,
						"interaction": {"item_id": "soda"}
					},

				]
			}
		],
		"cooking": [
						{
						"type": StepType.MOVE,
						"workstation": WS_PLATING,
						"prompt": "SERAHKAN KE PELANGGAN",
						"action": ActionType.NONE
					},
					{
						"type": StepType.ACTION,
						"workstation": WS_PLATING,
						"prompt": "BERIKAN SODA",
						"action": ActionType.PLATE,
						"interaction": {"item_id": "soda"}
					},
				]
	}
}
