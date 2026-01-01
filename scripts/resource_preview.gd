extends Control

var rarity: int
var resource_name: String
var price: int
var amount: int
var damage: int

func init(given_resource_name: String, resource_image: Texture2D, common_price: int, rare_price: int, legendary_price: int):
	resource_name = given_resource_name
	rarity = Rarity.LEGENDARY if resource_name.contains("legendary") else Rarity.RARE if resource_name.contains("rare") else Rarity.COMMON
	price = legendary_price if rarity == Rarity.LEGENDARY else rare_price if rarity == Rarity.RARE else common_price
	if resource_name.contains("soldier"):
		match rarity:
			Rarity.COMMON:
				damage = 20
			Rarity.RARE:
				damage = 35
			Rarity.LEGENDARY:
				damage = 50
		$DamageLabel.text = "+" + str(damage)
	$Preview.texture = resource_image
	$BuyButton.add_theme_color_override("font_color", Color.YELLOW if rarity == Rarity.LEGENDARY else Color.GREEN if rarity == Rarity.RARE else Color.WHITE)
	$BuyButton.text = tr("Buy for ") + str(price)
	amount = Database.get_value(resource_name + "_amount", 0)
	$AmountLabel.text = str(amount) + "x"
	if Database.get_value("denar", 0) < price:
		$BuyButton.disabled = true

func reload():
	init(resource_name, $Preview.texture, price, price, price)

func _on_buy_button_pressed() -> void:
	if Database.get_value("denar", 0) >= price:
		Database.set_value(resource_name + "_amount", amount + 1)
		Database.set_value("denar", Database.get_value("denar", 0) - price)
		get_parent().get_parent().get_parent().reload()
