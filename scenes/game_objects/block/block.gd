extends RigidBody3D
class_name Block

const COLOURS = [Color.RED, Color.GREEN, Color.BLUE]
const USE_PHYSICS = true

signal settled

@export var horizontal_speed := 3.0
@export var falling_speed := 1.0

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

var input_vector := Vector2()
var falling := true

func world_height() -> float:
    var shape = collision_shape_3d.shape as BoxShape3D
    return global_position.y + shape.size[1]/2

func _input(event: InputEvent) -> void:
    if falling:
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

    if falling and linear_velocity.y > -falling_speed / 2:
        print('settled')
        falling = false
        input_vector = Vector2.ZERO
        freeze = true
        settled.emit()

func _on_body_entered(body: CollisionObject3D) -> void:
    print(body)
    if body.get_collision_layer_value(1) and falling:
        print('settled')
        falling = false
        input_vector = Vector2.ZERO
        gravity_scale = 1
        physics_material_override.friction = 1
        lock_rotation = false
        set_collision_mask_value(2, false)
        settled.emit()
