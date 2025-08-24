extends Node2D

var enemy = false
var resume = true
var freezed := false
var enemy_soldier = null
var rarity: int
var damage: int
var sword := false
const damages = [20, 35, 50]
@onready var rng = RandomNumberGenerator.new()
@onready var life: float = rng.randf_range(90, 110)

func init(given_enemy: bool, given_rarity: int, weapon: String):
	enemy = given_enemy
	scale.x = -1 if enemy else 1
	rarity = given_rarity
	damage = damages[rarity] + randi_range(-10, 10)
	if enemy:
		$Texture.material = ShaderMaterial.new()
		$Texture.material.shader = load("res://assets/shaders/soldier.gdshader")
	match rarity:
		Rarity.COMMON:
			$Texture.texture = load("res://assets/soldiers/soldier_common.svg")
		Rarity.RARE:
			$Texture.texture = load("res://assets/soldiers/soldier_rare.svg")
		Rarity.LEGENDARY:
			$Texture.texture = load("res://assets/soldiers/soldier_legendary.svg")
	if weapon.contains("sword"):
		$WeaponTexture.position = Vector2i(45, -39)
		$SFXPlayer2D.stream = load("res://assets/audio/sword_hit.wav")
		sword = true
	$WeaponTexture.texture = load(weapon)
	$SFXPlayer2D.volume_linear = Database.get_value("sfx_volume", 100.0) / 100.0

func _process(delta: float) -> void:
	if not freezed:
		if resume:
			position.x += get_viewport_rect().size.x / 10.0 * delta * (-1 if enemy else 1)
		if sword:
			$AnimationPlayer.current_animation = "RESET" if resume and not freezed else "soldier_sword_fight"
		else:
			$AnimationPlayer.active = false
			$WeaponTexture.position = Vector2i(63, 1)
		if life <= 0:
			queue_free()
		if enemy_soldier != null:
			enemy_soldier.life -= damage * delta
		if position.x < -100 and enemy:
			@warning_ignore("integer_division")
			get_parent().get_parent().reduce_life_self(damage / 2)
			queue_free()
		elif position.x > get_viewport_rect().size.x + 100 and not enemy:
			@warning_ignore("integer_division")
			get_parent().get_parent().reduce_life_enemy(damage / 2)
			queue_free()


func _on_timer_timeout() -> void:
	if not resume and not freezed and $SFXPlayer2D.stream != null:
		$SFXPlayer2D.play()
