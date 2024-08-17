extends Node3D

@export var block_scenes: Array[PackedScene]

var current_block: Block = null
var tower_height := 0.0

func _ready() -> void:
    spawn_block()

func spawn_block() -> void:
    current_block = block_scenes.pick_random().instantiate() as Block
    add_child(current_block)
    current_block.position.y = tower_height + 10.0

    # TODO: Rotating can currently cause two blocks to collide while they're
    # sliding past each other.
    current_block.rotate_x(randi_range(0, 3) * (PI / 2))
    current_block.rotate_y(randi_range(0, 3) * (PI / 2))
    current_block.rotate_z(randi_range(0, 3) * (PI / 2))

    current_block.settled.connect(_on_block_settled)

func _on_block_settled() -> void:
    tower_height = max(tower_height, current_block.world_height())
    print('Tower height:', tower_height)
    current_block.settled.disconnect(_on_block_settled)
    spawn_block()
