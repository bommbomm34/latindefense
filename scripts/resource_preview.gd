extends Control

var rarity: int
var resource_name: String
var base_price: int
var price: int
var amount: int
var damage: String
var multiplier := 1

func init(given_resource_name: String, resource_image: Texture2D, given_base_price: int):
	resource_name = given_resource_name
	rarity = Rarity.LEGENDARY if resource_name.contains("legendary") else Rarity.RARE if resource_name.contains("rare") else Rarity.COMMON
	base_price = given_base_price
	price = base_price
	_on_bulk_buy_button_item_selected($BuyButton/BulkBuyButton.selected)
	set_damage()
	$DamageLabel.text = "+" + damage
	$Preview.texture = resource_image
	$BuyButton.add_theme_color_override("font_color", Color.YELLOW if rarity == Rarity.LEGENDARY else Color.GREEN if rarity == Rarity.RARE else Color.WHITE)
	$BuyButton.text = tr("Buy for ") + str(price)
	amount = Database.get_value(resource_name + "_amount", 0)
	$AmountLabel.text = str(amount) + "x"
	if Database.get_value("denar", 0) < price:
		$BuyButton.disabled = true

func reload():
	init(resource_name, $Preview.texture, base_price)

func _on_buy_button_pressed() -> void:
	if Database.get_value("denar", 0) >= price:
		Database.set_value(resource_name + "_amount", amount + multiplier)
		Database.set_value("denar", Database.get_value("denar", 0) - price)
		get_parent().get_parent().get_parent().reload()

func set_damage():
	if resource_name.contains("soldier"):
		match rarity:
			Rarity.COMMON:
				damage = "20"
			Rarity.RARE:
				damage = "35"
			Rarity.LEGENDARY:
				damage = "50"
	elif resource_name.contains("farmer"):
		match rarity:
			Rarity.COMMON: 
				damage = "0.1x"
			Rarity.RARE:
				damage = "0.3x"
			Rarity.LEGENDARY:
				damage = "0.5x"

func parse_bulk_multiplier(text: String) -> int:
	if text == "MAX":
		var current_denar = Database.get_value("denar", 0)
		return max(1, floori(float(current_denar) / float(base_price))) # Maximum amount
	else:
		return int(text.split("x")[0])


func _on_bulk_buy_button_item_selected(index: int) -> void:
	var current_denar = Database.get_value("denar", 0)
	multiplier = parse_bulk_multiplier($BuyButton/BulkBuyButton.get_item_text(index))
	price = base_price * multiplier
	$BuyButton.text = tr("Buy for ") + str(price)
	$BuyButton.disabled = current_denar < price
