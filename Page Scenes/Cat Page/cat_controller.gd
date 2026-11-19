extends Node

var cat_photos : Array
var cat_photos_path : String = "res://Page Scenes/Cat Page/Cat Photos/"
const _20220314_115430 = preload("uid://mg1qyq3quplx")
const _20220531_163259 = preload("uid://bpq7hmephi0ht")
const _20230128_013750 = preload("uid://c3dt4ob1xnsko")
const _20231013_231653 = preload("uid://csfw4v2erk2jx")
const _20231028_142748 = preload("uid://c3xutqae3fpjl")
const _20231028_142841 = preload("uid://chkcppxobo2xe")
const _20240114_135842 = preload("uid://bxgt5lgpa1et3")
const _20240121_005730 = preload("uid://b7ioacp6k0tx1")
const _20240218_151901 = preload("uid://bsvxfdkhftedb")
const _20240311_161145 = preload("uid://dchlcktns84cx")
const _20240525_172318 = preload("uid://cat3igo4gd5ys")
const _20240724_191916 = preload("uid://b50mxoourxybh")
const _20240809_125428_IMG_6164 = preload("uid://c7r32qgfmr3dr")
const _20241231_173721_IMG_7587 = preload("uid://bb8ygg2embtc0")
const _20241231_173722_IMG_7588 = preload("uid://l6m21bwr6h38")
const _20250618_133741 = preload("uid://cvp12k717l4qk")
const _20250702_124215_IMG_8886 = preload("uid://2eexj2cpaasg")
const _20251023_163139 = preload("uid://cg2glxwbeeba5")
const _20251210_153830 = preload("uid://bfa4u3ywjm6ch")
const _20251213_111518 = preload("uid://dwenite7peiyq")
const _20260208_130017 = preload("uid://daiw6mjyd28cb")
const _20260715_132701 = preload("uid://b2v58uol7xoge")
const _20260730_185921 = preload("uid://dlqgbpg6hllbr")
const _20260905_131354 = preload("uid://duv4asckemixs")
const _20260925_142632 = preload("uid://csgiqa676aajr")
const _20260925_152517 = preload("uid://dc2d7kvya6pcr")
const _20261101_114410 = preload("uid://okvvm5gupv8b")
const IMG_5381 = preload("uid://odelxu6ipqam")
const IMG_20230517_203111588 = preload("uid://c0bxmlwjiwll0")
const MESSENGER_CREATION_6E_68995C_5F_01_4788_9F_92_3BC_159FE_6AE_4 = preload("uid://dkwyleaaje60a")
const MESSENGER_CREATION_210782F_0_F_853_41CA_AF_20_3ED_86FB_9B_04C = preload("uid://be8uh347cnll0")
const MESSENGER_CREATION_929192EA_1707_47DB_A_9F_8_08F_71A_461B_7A = preload("uid://kn4ba00pdg5l")
const MESSENGER_CREATION_A_336E_646_DA_38_4115_9D_2A_58FEA_80BD_588 = preload("uid://cib11k7vs13s2")
const MESSENGER_CREATION_DBCF_8F_5B_76E_9_4863_AAB_8_B_915FD_01AB_29 = preload("uid://c1stmedm0mw8f")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var photo_paths = get_project_files(cat_photos_path)
	for photo_path in photo_paths:
		cat_photos.append(load(photo_path))
	
	print(cat_photos.size())

func get_random_cat_photo():
	pass

func get_project_files(path: String) -> PackedStringArray:
	# Returns all file names in the directory (subdirectories end with "/")
	var items: PackedStringArray = ResourceLoader.list_directory(path)
	var files: PackedStringArray = []
	
	for item in items:
		if not item.ends_with("/"):
			files.append(path.path_join(item))
			
	return files
