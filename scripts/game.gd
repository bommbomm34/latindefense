extends Control

@onready var Soldier := preload("res://scenes/Soldier.tscn")
@onready var multiplier: float = Database.get_value("farmer_common_amount", 0) * 0.1 + Database.get_value("farmer_rare_amount", 0) * 0.3 + Database.get_value("farmer_legendary_amount", 0) * 0.5 + 1
@onready var fight_against: String = Database.get_temp_var("fight_against", "Noricum")
@onready var life_enemy: int = min(max(Database.get_value(fight_against + "_life", 7000), 0), 100)
@onready var life_self: int = min(max(Database.get_value("self_life", 7000), 0), 100)
@onready var previous_life_enemy: int = Database.get_value(fight_against + "_life", 7000)
@onready var previous_life_self: int = Database.get_value("self_life", 7000)
var rarities := [Rarity.LEGENDARY, Rarity.RARE, Rarity.COMMON]
var enemy_count := 0
var self_soldier_order := []
var enemy_soldier_order := []
var last_soldier_spawn := 0
var top_limit := 900
var bottom_limit := 100
const round_off_factor := 200
const denar_icon_suffix := " [img=80x80]res://assets/icons/denar.png[/img]"
const color_suffix := "[/color]"
const red_color_praefix := "[color=ff0000]"
const green_color_praefix := "[color=00ff00]"
const yellow_color_praefix := "[color=ffff00]"
const reward := 300
const anti_reward := -100
const sword_common := "res://assets/weapons/sword_common.svg"
const sword_rare := "res://assets/weapons/sword_rare.svg"
const sword_legendary := "res://assets/weapons/sword_legendary.svg"
const bow_common := "res://assets/weapons/bow_common.svg"
const bow_rare := "res://assets/weapons/bow_rare.svg"
const bow_legendary := "res://assets/weapons/bow_legendary.svg"

func _ready() -> void:
	$MultiplierLabel.text = str(multiplier) + "x"
	update_values()
	init_soldier_order()
	var enemy_soldier_count = Database.get_value(fight_against + "_soldier_count", 0)
	for i in range(enemy_soldier_count):
		if i % 10 == 0 and i != 0:
			enemy_soldier_order.append(Rarity.LEGENDARY)
		elif i % 5 == 0 and i != 0:
			enemy_soldier_order.append(Rarity.RARE)
		else:
			enemy_soldier_order.append(Rarity.COMMON)
	enemy_soldier_order.shuffle()
	$FightAgainstLabel.text = fight_against

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		spawn_soldier(Vector2(0, round_off(max(bottom_limit, min(top_limit, event.position.y)))))

func spawn_soldier(pos: Vector2, enemy: bool = false):
	if check_distance(pos, enemy):
		var soldier = Soldier.instantiate()
		var order = (enemy_soldier_order if enemy else self_soldier_order)
		if not order.is_empty():
			var rarity = order.get(0)
			order.remove_at(0)
			soldier.position = pos
			soldier.init(enemy, rarity, get_weapons(rarity).get(1))
			$Soldiers.add_child(soldier)
			last_soldier_spawn = Time.get_ticks_msec()

func init_soldier_order():
	var common = Database.get_value("soldier_common_amount", 0)
	var rare = Database.get_value("soldier_rare_amount", 0)
	var legendary = Database.get_value("soldier_legendary_amount", 0)
	
	while common + rare + legendary > 0:
		match randi_range(0, 2):
			0:
				if common > 0:
					common -= 1
					self_soldier_order.append(Rarity.COMMON)
			1:
				if rare > 0:
					rare -= 1
					self_soldier_order.append(Rarity.RARE)
			2:
				if legendary > 0:
					legendary -= 1
					self_soldier_order.append(Rarity.LEGENDARY)
	self_soldier_order.shuffle()

func get_weapons(rarity: int):
	match rarity:
		Rarity.COMMON:
			return [bow_common, sword_common]
		Rarity.RARE:
			return [bow_rare, sword_rare]
		Rarity.LEGENDARY:
			return [bow_legendary, sword_legendary]

func check_distance(pos: Vector2, enemy: bool):
	for soldier in $Soldiers.get_children():
		if pos.distance_to(soldier.position) < 50 and soldier.enemy == enemy:
			return false
	return true

func _process(_delta: float) -> void:
	if not $Menu.visible:
		if (self_soldier_order.is_empty() and enemy_soldier_order.is_empty() and $Soldiers.get_children().is_empty()) or is_total_life_empty():
			await get_tree().process_frame
			freeze()
			exit((reward * multiplier) if life_self > life_enemy else (anti_reward if life_self < life_enemy else -1))
	for soldier in $Soldiers.get_children():
		var enemy_soldier = if_soldier_must_stop(soldier)
		soldier.resume = enemy_soldier == null
		soldier.enemy_soldier = enemy_soldier
	update_values()

func freeze():
	for soldier in $Soldiers.get_children():
		soldier.freezed = true
	enemy_soldier_order.clear()
	self_soldier_order.clear()

func is_total_life_empty() -> bool:
	return (previous_life_self - 100 + life_self) <= 0 or (previous_life_enemy - 100 + life_enemy) <= 0

func update_values():
	$SelfLifeLabel.text = str(life_self)
	$EnemyLifeLabel.text = str(life_enemy)
	$SoldierCommonAmountLabel.text = str(calculate_amount(Rarity.COMMON))
	$SoldierRareAmountLabel.text = str(calculate_amount(Rarity.RARE))
	$SoldierLegendaryAmountLabel.text = str(calculate_amount(Rarity.LEGENDARY))
	$TotalEnemyAmount.text = str(enemy_soldier_order.size())

func update_limits():
	var addition = get_viewport_rect().size.y - 1080
	bottom_limit = 100 + addition
	top_limit = 900 + addition

func calculate_amount(rarity: int) -> int:
	var amount := 0
	for soldier_rarity in self_soldier_order:
		amount += 1 if soldier_rarity == rarity else 0
	return amount

func if_soldier_must_stop(given_soldier):
	for soldier in $Soldiers.get_children():
		if given_soldier.position.distance_to(soldier.position) < 100 and not given_soldier.enemy == soldier.enemy and soldier.position.x < 1920 and soldier.position.x > 0:
			return soldier
	return null

func spawn_enemy() -> void:
	if not enemy_soldier_order.is_empty():
		spawn_soldier(Vector2i(get_viewport_rect().size.x + 100, find_y_for_enemy()), true)
		$Timer.wait_time = randf_range(0.1, 0.5)

func get_own_soldier_count():
	var count := 0
	for soldier in $Soldiers.get_children():
		if not soldier.enemy:
			count += 1
	return count

func find_y_for_enemy() -> int:
	const MIN_Y = 200
	const MAX_Y = 900
	var defense := randi_range(1, 10) < 8
	var possible_y_values := []
	for i in range(MIN_Y, MAX_Y):
		var possible_y = round_off(i)
		var possible_y_works := true
		for soldier in $Soldiers.get_children():
			var other_y = round_off(soldier.position.y)
			if possible_y == other_y:
				possible_y_works = false
				break
		if !possible_y_works if defense else possible_y_works:
			possible_y_values.append(possible_y)
	if possible_y_values.is_empty():
		return round_off(randi_range(MIN_Y, MAX_Y))
	else:
		return possible_y_values.pick_random()

func round_off(value) -> int:
	return max(round(value / round_off_factor) * round_off_factor, 200)

func reduce_life_self(damage: int):
	life_self -= damage

func reduce_life_enemy(damage: int):
	life_enemy -= damage

func exit(award := 0):
	Database.add_value("self_life", -100 + life_self)
	Database.add_value(fight_against + "_life", -100 + life_enemy)
	$Menu/TotalEnemyLifeLabel.text = str(Database.get_value(fight_against + "_life", 7000))
	$Menu/TotalSelfLifeLabel.text = str(Database.get_value("self_life", 7000))
	Database.add_value("denar", get_real_award(award))
	$Menu.visible = true
	var result_label := $Menu/ColorRect/ResultLabel
	if Database.get_value(fight_against + "_life", 7000) <= 0:
		$Menu/PlayAgainButton.disabled = true
		Database.set_value(fight_against + "_life", 7000)
		Database.set_value(fight_against + "_owned", true)
		Database.set_value("self_life", 7000)
		Database.add_value("denar", Database.get_value(fight_against + "_denar", 0))#
		award += Database.get_value(fight_against + "_denar", 0)
	if Database.get_value("self_life", 7000) <= 0:
		Database.add_value("denar", get_real_award(-500))
		Database.set_value("self_life", 7000)
		award -= 500
	if award > 0:
		result_label.text = green_color_praefix + tr("Won ") + color_suffix + str(award) + denar_icon_suffix
	elif award == -1:
		result_label.text = yellow_color_praefix + tr("Drawn ") + color_suffix
	else: 
		result_label.text = red_color_praefix + tr("Lost ") + color_suffix + str(abs(max(award, -100))) + denar_icon_suffix

func _on_back_to_home_button_pressed() -> void:
	call_deferred("change_to_scene", "res://scenes/Home.tscn")

func _on_play_again_button_pressed() -> void:
	get_tree().reload_current_scene()

func get_real_award(award: int):
	var denar: int = Database.get_value("denar", 0)
	return max((award if award >= 0 else (denar * -1 if denar < abs(award) else award)) if award != -1 else 0, -100)

func change_to_scene(path: String):
	get_tree().change_scene_to_file(path)
