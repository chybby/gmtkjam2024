extends RigidBody3D
class_name Block

const COLOURS := [Color.RED, Color.GREEN, Color.BLUE]
const USE_PHYSICS := false
const DISCRETE_MOTION := true

signal settled

@export var horizontal_speed := 3.0
@export var falling_speed := 1.0

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

var input_vector := Vector2.ZERO
var motion := Vector3.ZERO
var falling := true

func world_height() -> float:
    var shape = collision_shape_3d.shape as BoxShape3D
    return global_position.y + shape.size[1]/2

func _input(event: InputEvent) -> void:
    if falling:
        if DISCRETE_MOTION:
            if event.is_action_pressed("block_move_left"):
                motion = Vector3.LEFT
            elif event.is_action_pressed("block_move_right"):
                motion = Vector3.RIGHT
            elif event.is_action_pressed("block_move_up"):
                motion = Vector3.FORWARD
            elif event.is_action_pressed("block_move_down"):
                motion = Vector3.BACK
        else:
            input_vector = Input.get_vector("block_move_left", "block_move_right", "block_move_up", "block_move_down")
            linear_velocity.x = input_vector.x * horizontal_speed
            linear_velocity.z = input_vector.y * horizontal_speed


func _ready() -> void:
    linear_velocity.y = -falling_speed
    var material = mesh.material_override as StandardMaterial3D
    material.albedo_color = COLOURS.pick_random()

func _physics_process(delta: float) -> void:
    if USE_PHYSICS:
        if position.y < -1.0:
            queue_free()

    if DISCRETE_MOTION:
        if not motion.is_zero_approx() and not test_move(transform, motion):
            position += motion
        motion = Vector3.ZERO

    if falling and linear_velocity.y > -falling_speed / 2:
        falling = false
        input_vector = Vector2.ZERO
        freeze = true
        settled.emit()

func _on_body_entered(body: CollisionObject3D) -> void:
    if body.get_collision_layer_value(1) and falling:
        falling = false
        input_vector = Vector2.ZERO
        gravity_scale = 1
        linear_damp_mode = DAMP_MODE_COMBINE
        physics_material_override.friction = 1
        lock_rotation = false
        set_collision_mask_value(2, false)
        settled.emit()
