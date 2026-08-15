extends RefCounted
class_name WorkstationInventory

## R-P3-10 extension --- "Barang di workstation prep".
##
## Tiap workstation prep (Kulkas, Tempat Nasi, dst) FIXED nyimpen semua
## barang yang mungkin kepake di game -- gak berubah tergantung resep aktif
## hari itu (lihat keputusan desain: "Fixed, semua barang yang mungkin
## dipakai game selalu ada di situ").
##
## Dipakai oleh Workstation.run_take_action() lewat ItemPickManager buat
## nunjukkin SEMUA nama barang sekaligus ke player. Benar/salahnya baru
## dicek belakangan terhadap `interaction.item_id` punya step TAKE yang
## sedang aktif (lihat RecipeData) -- data ini sendiri TIDAK tau resep
## mana yang lagi jalan.

const ITEMS: Dictionary = {
	"REFRIGERATOR": [
		{"item_id": "daging_cincang", "label": "DAGING CINCANG"},
		{"item_id": "daging_wagyu", "label": "DAGING WAGYU"},
		{"item_id": "daging", "label": "DAGING"},
		{"item_id": "telur", "label": "TELUR"},
		{"item_id": "butter", "label": "BUTTER"},
		{"item_id": "adonan", "label": "ADONAN"},
		{"item_id": "patty", "label": "PATTY"},
		{"item_id": "air_mineral", "label": "AIR MINERAL"},
		{"item_id": "soda", "label": "SODA"},
	],
	"RICE_STORAGE": [
		{"item_id": "nasi", "label": "NASI"},
	],
	"BUN_STORAGE": [
		{"item_id": "bun_burger", "label": "BUN BURGER"},
	],
	"PRODUCE": [
		{"item_id": "buah", "label": "BUAH"},
		{"item_id": "sayur", "label": "SAYUR"},
	],
	"SEASONING": [
		{"item_id": "bumbu", "label": "BUMBU"},
	],
}


## Balikin salinan (bukan referensi) array item buat 1 workstation command.
## Kosong kalau workstation itu gak punya inventory (mis. STOVE, PLATING).
static func get_items(workstation_command: String) -> Array:
	return ITEMS.get(workstation_command.to_upper(), []).duplicate(true)


static func has_items(workstation_command: String) -> bool:
	return ITEMS.has(workstation_command.to_upper())
