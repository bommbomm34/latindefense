extends Control

const bgmusic_war_resource_path = "res://assets/audio/bgmusic_war.mp3"
const bgmusic_regular_resource_path = "res://assets/audio/bgmusic_regular.mp3"
@onready var bgmusic_war_stream = preload(bgmusic_war_resource_path)
@onready var bgmusic_regular_stream = preload(bgmusic_regular_resource_path)

func _ready() -> void:
	set_volume()

func _process(_delta: float) -> void:
	set_volume()
	if get_parent().get_node_or_null("Game") != null and $BackgroundMusicPlayer.stream.resource_path != bgmusic_war_resource_path:
		$BackgroundMusicPlayer.stream = bgmusic_war_stream
		$BackgroundMusicPlayer.play()
	if get_parent().get_node_or_null("Game") == null and $BackgroundMusicPlayer.stream.resource_path != bgmusic_regular_resource_path:
		$BackgroundMusicPlayer.stream = bgmusic_regular_stream
		$BackgroundMusicPlayer.play()
	#format_buttons()

func _on_bgmusic_finished() -> void:
	$BackgroundMusicPlayer.play()

func set_volume():
	$BackgroundMusicPlayer.volume_linear = Database.get_value("music_volume", 100) / 100.0

#func format_buttons():
	#if get_parent().get_children().size() == 2:
		#var other_node = get_parent().get_node_or_null("Home")
		#other_node = other_node if other_node != null else get_parent().get_child(1)
		#for child in other_node.get_children(true):
			#if child is Button:
				#format_button(child)
