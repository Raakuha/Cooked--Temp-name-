extends RefCounted
class_name RecipeData

enum StepType{
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

const RECIPES = {
	"nasgor_goreng": [
#		STEP 0
		{
			"type" : StepType.MOVE,
			"workstation" : "REFRIGERATOR",
			"prompt": "KE KULKAS",
			"action" : ActionType.NONE
			
		}, 
#		STEP 1
		{
			"type" : StepType.ACTION,
			"workstation" : "REFRIGERATOR",
			"prompt": "AMBIL NASI SISA",
			"action" : ActionType.TAKE
		},
#		STEP 2
		{
			"type" : StepType.ACTION,
			"workstation" : "REFRIGERATOR",
			"prompt": "AMBIL DAGING CINCANG",
			"action" : ActionType.TAKE
		},
#		STEP 3
		{
			"type" : StepType.ACTION,
			"workstation" : "REFRIGERATOR",
			"prompt": "AMBIL BUMBU",
			"action" : ActionType.TAKE
		},
#		STEP 4
		{
			"type" : StepType.ACTION,
			"workstation" : "REFRIGERATOR",
			"prompt": "AMBIL TELOR",
			"action" : ActionType.TAKE
		},
#		STEP 5
		{
			"type" : StepType.MOVE,
			"workstation" : "STOVE",
			"prompt": "LETAKKAN BAHAN DEKAT WAJAN",
			"action" : ActionType.NONE
		},
#		STEP 6
		{
			"type" : StepType.ACTION,
			"workstation" : "STOVE",
			"prompt": "PANASKAN MINYAK",
			"action" : ActionType.OPEN
		},
#		STEP 7
		{
			"type" : StepType.ACTION,
			"workstation" : "STOVE",
			"prompt": "MASUKKAN BUMBU PENYEDAP",
			"action" : ActionType.ADD
		},
#		STEP 8
		{
			"type" : StepType.ACTION,
			"workstation" : "STOVE",
			"prompt": "MASUKKAN TELOR",
			"action" : ActionType.ADD
		},
#		STEP 9
		{
			"type" : StepType.ACTION,
			"workstation" : "STOVE",
			"prompt": "MASUKKAN DAGING CINCANG SEGAR",
			"action" : ActionType.ADD
		},
#		STEP 10
		{
			"type" : StepType.ACTION,
			"workstation" : "STOVE",
			"prompt": "TERAKHIR MASUKKAN NASI",
			"action" : ActionType.ADD
		},
#		STEP 11
		{
			"type" : StepType.ACTION,
			"workstation" : "STOVE",
			"prompt": "RATAKAN NASI DENGAN BUMBU LAINNYA",
			"action" : ActionType.MIX
		},
#		STEP 12
		{
			"type" : StepType.ACTION,
			"workstation" : "STOVE",
			"prompt": "HIDANGKAN",
			"action" : ActionType.SERVE
		}
		
	]
	
}
