extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func play_exploding() -> void:
    animation_player.play("exploding")
