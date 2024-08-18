extends Node3D

@onready var world: Node3D = %World
@onready var player: Player = $Player
@onready var top_down_camera_3d: Camera3D = %TopDownCamera3D
@onready var cinematic_camera_pivot: Node3D = $CinematicCameraPivot
@onready var cinematic_camera_3d: Camera3D = $CinematicCameraPivot/CinematicCamera3D
@onready var hud: CanvasLayer = $HUD
@onready var settings: CanvasLayer = $Settings
@onready var block_count_label: Label = %BlockCountLabel
@onready var health_label: Label = %HealthLabel

@export var cinematic_camera_rotate_speed := 1.0
@export var cinematic_camera_climb_speed := 0.5

var game_over := false

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("pause"):
        if settings.visible:
            settings.visible = false
            get_tree().paused = false
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
        else:
            get_tree().paused = true
            settings.visible = true
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    player.died.connect(_on_player_died)
    settings.closed.connect(_on_settings_closed)

func _physics_process(delta: float) -> void:
    top_down_camera_3d.rotation.y = player.look_angle()
    top_down_camera_3d.position.x = player.position.x
    top_down_camera_3d.position.z = player.position.z

func _process(delta: float) -> void:
    cinematic_camera_pivot.rotate_y(cinematic_camera_rotate_speed * delta)
    if game_over and cinematic_camera_pivot.position.y < world.tower_height:
        cinematic_camera_pivot.position.y += cinematic_camera_climb_speed * delta
    block_count_label.text = str(world.blocks_remaining)
    health_label.text = str(player.health)

func _on_player_died() -> void:
    cinematic_camera_3d.current = true
    game_over = true
    hud.visible = false

func _on_settings_closed() -> void:
    settings.visible = false
    get_tree().paused = false
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
