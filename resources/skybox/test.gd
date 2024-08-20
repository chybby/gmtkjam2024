extends Node

@export var sky_material: ShaderMaterial
@export var player_height: float


func _process(delta: float) -> void: 
    sky_material.set_shader_parameter("player_height", player_height)
