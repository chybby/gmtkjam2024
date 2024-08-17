extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var top_down_camera_3d: Camera3D = $CanvasLayer/SubViewportContainer/SubViewport/TopDownCamera3D


func _physics_process(delta: float) -> void:
    top_down_camera_3d.rotation.y = player.look_angle()
