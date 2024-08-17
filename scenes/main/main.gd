extends Node3D

@onready var player: Player = $Player
@onready var top_down_camera_3d: Camera3D = $HUD/SubViewportContainer/SubViewport/TopDownCamera3D
@onready var cinematic_camera_pivot: Node3D = $CinematicCameraPivot
@onready var cinematic_camera_3d: Camera3D = $CinematicCameraPivot/CinematicCamera3D
@onready var hud: CanvasLayer = $HUD

@export var cinematic_camera_rotate_speed := 1.0
@export var cinematic_camera_climb_speed := 0.5

var game_over := false

func _ready() -> void:
    player.died.connect(_on_player_died)

func _physics_process(delta: float) -> void:
    top_down_camera_3d.rotation.y = player.look_angle()

func _process(delta: float) -> void:
    cinematic_camera_pivot.rotate_y(cinematic_camera_rotate_speed * delta)
    if game_over:
        cinematic_camera_pivot.position.y += cinematic_camera_climb_speed * delta

func _on_player_died() -> void:
    cinematic_camera_3d.current = true
    game_over = true
    hud.visible = false
