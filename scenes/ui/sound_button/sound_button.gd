@icon("res://scenes/ui/sound_button/sound_button.svg")
class_name SoundButton
extends Button

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func on_pressed() -> void:
    audio_stream_player.play()
