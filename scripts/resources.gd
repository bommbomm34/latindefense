extends Control

@onready var resources_container := $ScrollContainer/ResourcesContainer
@export_group("Farmer prices")
@export var farmer_common_base_price := 100
@export var farmer_rare_base_price := 300
@export var farmer_legendary_base_price := 500
@export_group("Soldier prices")
@export var soldier_common_base_price := 200
@export var soldier_rare_base_price := 500
@export var soldier_legendary_base_price := 1000

func _ready():
	var price_multiplier := get_price_multiplier()
	var farmer_common_price := farmer_common_base_price * price_multiplier
	var farmer_rare_price := farmer_rare_base_price * price_multiplier
	var farmer_legendary_price := farmer_legendary_base_price * price_multiplier
	var soldier_common_price := soldier_common_base_price * price_multiplier
	var soldier_rare_price := soldier_rare_base_price * price_multiplier
	var soldier_legendary_price := soldier_legendary_base_price * price_multiplier

	load_resources("soldiers", soldier_common_price, soldier_rare_price, soldier_legendary_price)
	load_resources("farmers", farmer_common_price, farmer_rare_price, farmer_legendary_price)

func load_resources(resources_name: String, common_price: int, rare_price: int, legendary_price: int):
	const rarities := ["common", "rare", "legendary"]
	var ResourcePreview := preload("res://scenes/ResourcePreview.tscn")
	for i in rarities.size():
		var rarity = rarities[i]
		var resource_path = resources_name.substr(0, resources_name.length() - 1) + "_" + rarity + ".svg"
		var resource_preview := ResourcePreview.instantiate()
		var price = legendary_price if i == Rarity.LEGENDARY else rare_price if i == Rarity.RARE else common_price
		resources_container.add_child(resource_preview)
		resource_preview.init(resource_path.split(".svg")[0], load("res://assets/" + resources_name + "/" + resource_path), price)

func reload():
	for child in resources_container.get_children():
		child.reload()

func get_price_multiplier() -> int:
	var owned_provinces := 0
	for key: String in Database.dictionary:
		if key.ends_with("_owned"):
			owned_provinces += 1
	return owned_provinces
