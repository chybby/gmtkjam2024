extends Node3D

@onready var world: World = %World
@onready var player: Player = $Player

@onready var top_down_camera_3d: Camera3D = %TopDownCamera3D
@onready var cinematic_camera_pivot: Node3D = $CinematicCameraPivot
@onready var cinematic_camera_3d: Camera3D = $CinematicCameraPivot/CinematicCamera3D

@onready var hud: CanvasLayer = %HUD
@onready var health: HBoxContainer = %Health
@onready var block_count_label: Label = %BlockCountLabel
@onready var rerolls_label: Label = %RerollsLabel
@onready var rerolls: HBoxContainer = %Rerolls
@onready var height_label: Label = %HeightLabel
@onready var timer_label: Label = %TimerLabel
@onready var timer_container: HBoxContainer = %TimerContainer

@onready var warnings: Control = %Warnings

@onready var settings: CanvasLayer = $Settings
@onready var game_over_menu: CanvasLayer = $GameOver

@onready var chance: Chance = $Chance

@onready var intro_camera_3d: Camera3D = %IntroCamera3D

@export var cinematic_camera_rotate_speed := 1.0
@export var cinematic_camera_climb_speed := 0.5
@export var warning_scene: PackedScene

@export var full_heart_scene: PackedScene
@export var empty_heart_scene: PackedScene

@onready var hint: PanelContainer = %Hint
@onready var hint_label: RichTextLabel = %HintLabel
@onready var hint_animation_player: AnimationPlayer = %HintAnimationPlayer

@onready var chance_pickup_sound: AudioStreamPlayer = %ChancePickupSound
@onready var block_thump_sound: AudioStreamPlayer = %BlockThumpSound




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

var playing_intro_transition := false

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    GameEvents.game_over.connect(_on_game_over)
    settings.closed.connect(_on_settings_closed)
    game_over_menu.try_again.connect(_on_try_again)
    GameEvents.card_selected.connect(_on_card_selected)
    GameEvents.chance_picked_up.connect(_on_chance_picked_up)
    GameEvents.hint.connect(_on_hint)
    GameEvents.health_changed.connect(_on_health_changed)

    _on_health_changed()

    if not GlobalState.intro_mode:
        player.camera.current = true
        player.visible = true
        hud.offset.x = 0
        GameEvents.emit_game_started()

func _physics_process(delta: float) -> void:
    if GlobalState.rotate_minimap:
        top_down_camera_3d.rotation.y = player.look_angle()
    else:
        top_down_camera_3d.rotation.y = 0
    top_down_camera_3d.position.x = player.position.x
    top_down_camera_3d.position.z = player.position.z

func _process(delta: float) -> void:
    if GlobalState.intro_mode and not playing_intro_transition and world.blocks_placed == 5:
        playing_intro_transition = true

        # Tween from the intro camera to the player camera.
        var tween = get_tree().create_tween()
        tween.set_ease(Tween.EASE_IN)
        tween.set_trans(Tween.TRANS_QUAD)
        tween.set_parallel(true)
        tween.tween_property(intro_camera_3d, "fov", player.camera.fov, 5)
        tween.tween_property(intro_camera_3d, "position", player.camera.global_position, 5)
        await tween.finished
        player.camera.current = true

        block_thump_sound.play()
        world.blow_away_intro_blocks()

        # Tween in the HUD.
        hud.visible = true
        var hud_tween = get_tree().create_tween()
        hud_tween.set_ease(Tween.EASE_IN_OUT)
        hud_tween.set_trans(Tween.TRANS_QUAD)
        hud_tween.tween_property(hud, "offset:x", 0, 2)
        await hud_tween.finished

        GameEvents.emit_game_started()
        GlobalState.intro_mode = false
        player.visible = true

    if game_over:
        cinematic_camera_pivot.rotate_y(cinematic_camera_rotate_speed * delta)
        world.update_progress(clamp(cinematic_camera_pivot.position.y / world.heaven_height, 0.0, 1.0))
        if cinematic_camera_pivot.position.y < world.tower_height:
            cinematic_camera_pivot.position.y += cinematic_camera_climb_speed * delta
    else:
        world.update_progress(world.get_progress())

    block_count_label.text = str(world.blocks_remaining)
    if world.blocks_remaining == 0:
        block_count_label.add_theme_color_override('font_color', Color('#e32059'))
    else:
        block_count_label.add_theme_color_override('font_color', Color.WHITE)

    rerolls_label.text = str(world.rerolls)
    if world.rerolls > 0:
        rerolls.visible = true
    height_label.text = str(round(player.height()))

    # update_lava_timer()

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

func _on_game_over() -> void:
    cinematic_camera_3d.current = true
    game_over = true
    hud.visible = false
    if GlobalState.won:
        game_over_menu.allow_chaos_mode()
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
    chance_pickup_sound.play()
    pause()
    chance.show_chance_cards()

func _on_hint(text: String) -> void:
    hint_label.text = text
    hint_animation_player.play("show_hint")

func update_lava_timer():
    var time_left = world.get_lava_time_left()
    if (time_left == 0):
        timer_container.hide()
    else:
        timer_container.show()
        var time_text = str(round(time_left * 100) / 100)
        timer_label.text = time_text

func _on_health_changed() -> void:
    var max_hp = player.max_hp
    var hp = player.health

    for child in health.get_children():
        child.queue_free()

    #add empty hearts
    for i in max(0, max_hp - hp):
        var missing_hp = empty_heart_scene.instantiate()
        health.add_child(missing_hp)

    #add hearts
    for i in max(0, hp):
        var hp_obj = full_heart_scene.instantiate()
        health.add_child(hp_obj)
