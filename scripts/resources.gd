extends Control

@onready var resources_container := $ScrollContainer/ResourcesContainer
@export_group("Farmer prices")
@export var farmer_common_price := 100
@export var farmer_rare_price := 300
@export var farmer_legendary_price := 500
@export_group("Soldier prices")
@export var soldier_common_price := 500
@export var soldier_rare_price := 1000
@export var soldier_legendary_price := 2500

func _ready():
	load_resources("soldiers", soldier_common_price, soldier_rare_price, soldier_legendary_price)
	load_resources("farmers", farmer_common_price, farmer_rare_price, farmer_legendary_price)

func load_resources(resources_name: String, common_price: int, rare_price: int, legendary_price: int):
	const rarities := ["common", "rare", "legendary"]
	var ResourcePreview := preload("res://scenes/ResourcePreview.tscn")
	for rarity in rarities:
		var resource_path = resources_name.substr(0, resources_name.length() - 1) + "_" + rarity + ".svg"
		var resource_preview := ResourcePreview.instantiate()
		resources_container.add_child(resource_preview)
		resource_preview.init(resource_path.split(".svg")[0], load("res://assets/" + resources_name + "/" + resource_path), common_price, rare_price, legendary_price)

func reload():
	for child in resources_container.get_children():
		child.reload()
