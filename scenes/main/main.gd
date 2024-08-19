extends Node3D

@onready var world: World = %World
@onready var player: Player = $Player

@onready var top_down_camera_3d: Camera3D = %TopDownCamera3D
@onready var cinematic_camera_pivot: Node3D = $CinematicCameraPivot
@onready var cinematic_camera_3d: Camera3D = $CinematicCameraPivot/CinematicCamera3D

@onready var hud: CanvasLayer = $HUD
@onready var health: HBoxContainer = %Health
@onready var block_count_label: Label = %BlockCountLabel
@onready var rerolls_label: Label = %RerollsLabel
@onready var height_label: Label = %HeightLabel
@onready var timer_label: Label = %TimerLabel
@onready var timer_container: HBoxContainer = %TimerContainer

@onready var warnings: Control = %Warnings

@onready var settings: CanvasLayer = $Settings
@onready var game_over_menu: CanvasLayer = $GameOver

@onready var chance: Chance = $Chance

@export var cinematic_camera_rotate_speed := 1.0
@export var cinematic_camera_climb_speed := 0.5
@export var warning_scene: PackedScene

@export var full_heart_scene: PackedScene
@export var empty_heart_scene: PackedScene

@onready var hint: PanelContainer = %Hint
@onready var hint_label: RichTextLabel = %HintLabel


var game_over := false
var pause_counter := 0

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("pause"):
        if game_over_menu.visible or chance.visible:
            return

        if settings.visible:
            close_settings()
        else:
            open_settings()

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    player.died.connect(_on_player_died)
    settings.closed.connect(_on_settings_closed)
    game_over_menu.try_again.connect(_on_try_again)
    GameEvents.card_selected.connect(_on_card_selected)
    GameEvents.chance_picked_up.connect(_on_chance_picked_up)
    GameEvents.hint.connect(_on_hint)
    GameEvents.health_changed.connect(_on_health_changed)
    
    _on_health_changed()

func _physics_process(delta: float) -> void:
    if GlobalState.rotate_minimap:
        top_down_camera_3d.rotation.y = player.look_angle()
    else:
        top_down_camera_3d.rotation.y = 0
    top_down_camera_3d.position.x = player.position.x
    top_down_camera_3d.position.z = player.position.z

func _process(delta: float) -> void:
    if game_over:
        cinematic_camera_pivot.rotate_y(cinematic_camera_rotate_speed * delta)
        if cinematic_camera_pivot.position.y < world.tower_height:
            cinematic_camera_pivot.position.y += cinematic_camera_climb_speed * delta
    
    block_count_label.text = str(world.blocks_remaining)
    rerolls_label.text = str(world.rerolls)
    height_label.text = str(round(player.height()))
    
    update_lava_timer()

    for warning in warnings.get_children():
        warning.queue_free()
    for warning_direction in player.warning_directions:
        var warning := warning_scene.instantiate()
        warnings.add_child(warning)
        warning.position += warning_direction * 400

func unpause() -> void:
    pause_counter -= 1
    if pause_counter == 0:
        get_tree().paused = false
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func pause() -> void:
    pause_counter += 1
    get_tree().paused = true
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close_settings() -> void:
    settings.visible = false
    unpause()

func open_settings() -> void:
    settings.visible = true
    pause()

func _on_player_died() -> void:
    cinematic_camera_3d.current = true
    game_over = true
    hud.visible = false
    game_over_menu.visible = true
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_settings_closed() -> void:
    close_settings()

func _on_try_again(chaos_mode: bool) -> void:
    GlobalState.chaos_mode = chaos_mode
    get_tree().reload_current_scene()

func _on_card_selected() -> void:
    chance.hide()
    unpause()

func _on_chance_picked_up() -> void:
    pause()
    chance.show_chance_cards()

func _on_hint(text: String) -> void:
    hint_label.text = text
    hint.visible = true
    await get_tree().create_timer(5).timeout
    hint.visible = false
    
func update_lava_timer():
    var time_left = world.get_lava_time_left()
    if(time_left == 0):
        timer_container.hide()
    else:
        timer_container.show()
        var time_text = str(round(time_left * 100)/100)
        timer_label.text = time_text

func _on_health_changed() -> void:
    var max = player.max_hp
    var hp = player.health
    
    for child in health.get_children():
        child.queue_free()
    
    #add empty hearts
    for i in max(0, max - hp):
        var missing_hp = empty_heart_scene.instantiate()
        health.add_child(missing_hp)
    
    #add hearts
    for i in max(0, hp):
        var hp_obj = full_heart_scene.instantiate()
        health.add_child(hp_obj)
