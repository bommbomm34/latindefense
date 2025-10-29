extends Control

const bgmusic_war_resource_path = "res://assets/audio/bgmusic_war.wav"
const bgmusic_regular_resource_path = "res://assets/audio/bgmusic_regular.ogg"
@onready var bgmusic_war_stream = preload(bgmusic_war_resource_path)
@onready var bgmusic_regular_stream = preload(bgmusic_regular_resource_path)

func _process(_delta: float) -> void:
	set_volume()
	if get_parent().get_node_or_null("Game") != null and $BackgroundMusicPlayer.stream.resource_path != bgmusic_war_resource_path:
		$BackgroundMusicPlayer.stream = bgmusic_war_stream
		$BackgroundMusicPlayer.play()
	if get_parent().get_node_or_null("Game") == null and $BackgroundMusicPlayer.stream.resource_path != bgmusic_regular_resource_path:
		$BackgroundMusicPlayer.stream = bgmusic_regular_stream
		$BackgroundMusicPlayer.play()

func _on_bgmusic_finished() -> void:
	$BackgroundMusicPlayer.play()

func set_volume():
	$BackgroundMusicPlayer.volume_linear = Database.get_value("music_volume", 30) / 100.0
