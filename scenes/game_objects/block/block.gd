extends RigidBody3D
class_name Block

signal settled

@export var horizontal_speed := 3.0
@export var falling_speed := 1.0
@export var use_physics := false
@export var discrete_motion := true

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var minimap_model: MeshInstance3D = %Cube2
@onready var initial_s: float = minimap_model.mesh.surface_get_material(0).albedo_color.s

@onready var player: Player = get_tree().get_first_node_in_group('Player')

var input_vector := Vector2.ZERO
var motion := Vector3.ZERO
var falling := true

var tower_height: float = 0

func world_height() -> float:
    # TODO: fix
    return global_position.y

func _input(event: InputEvent) -> void:
    if falling:
        if GlobalState.intro_mode:
            if event.is_action_pressed("block_move_left"):
                motion = Vector3.LEFT
            elif event.is_action_pressed("block_move_right"):
                motion = Vector3.RIGHT

            if event.is_action_pressed("block_move_down"):
                linear_velocity.y = 8 * -falling_speed
        else:

            var player_angle: float = round(player.look_angle() / (PI/2)) * PI/2
            if discrete_motion:
                if event.is_action_pressed("block_move_left"):
                    motion = Vector3.LEFT
                elif event.is_action_pressed("block_move_right"):
                    motion = Vector3.RIGHT
                elif event.is_action_pressed("block_move_up"):
                    motion = Vector3.FORWARD
                elif event.is_action_pressed("block_move_down"):
                    motion = Vector3.BACK
                motion = motion.rotated(Vector3.UP, player_angle)
            else:
                input_vector = Input.get_vector("block_move_left", "block_move_right", "block_move_up", "block_move_down")
                linear_velocity.x = input_vector.x * horizontal_speed
                linear_velocity.z = input_vector.y * horizontal_speed

            if event.is_action_pressed("fast_fall"):
                linear_velocity.y = 4 * -falling_speed
            elif event.is_action_released("fast_fall"):
                linear_velocity.y = -falling_speed


func _ready() -> void:
    linear_velocity.y = -falling_speed
    if GlobalState.chaos_mode:
        use_physics = true

    GameEvents.tower_height_changed.connect(_on_tower_height_changed)

func _physics_process(delta: float) -> void:
    if use_physics:
        if position.y < -1.0:
            queue_free()
    else:
        if falling and linear_velocity.y > -falling_speed / 2:
            falling = false
            input_vector = Vector2.ZERO
            freeze = true
            position = position.round()
            settled.emit()

    if discrete_motion:
        if not motion.is_zero_approx() and not test_move(transform, motion):
            position += motion
        motion = Vector3.ZERO

    if not falling:
        var material = minimap_model.mesh.surface_get_material(0) as StandardMaterial3D

        material.albedo_color.s = max(initial_s * 0.75 - (initial_s * 0.75 * 0.05 * (tower_height - world_height())), 0.2)

func _on_tower_height_changed(height: float) -> void:
    tower_height = height

func _on_body_entered(body: CollisionObject3D) -> void:
    if use_physics and body.get_collision_layer_value(1) and falling:
        falling = false
        input_vector = Vector2.ZERO
        gravity_scale = 1
        linear_damp_mode = DAMP_MODE_COMBINE
        physics_material_override.friction = 1
        lock_rotation = false
        set_collision_mask_value(2, false)
        settled.emit()

func blow_away() -> void:
    gravity_scale = 1
    linear_damp_mode = DAMP_MODE_COMBINE
    physics_material_override.friction = 1
    lock_rotation = false
    set_collision_mask_value(2, false)
    freeze = false

    var direction = (global_position - player.global_position).normalized()

    apply_impulse(direction * 1500)
    await get_tree().create_timer(5).timeout
    queue_free()
