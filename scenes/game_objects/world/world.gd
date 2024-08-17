extends Node3D

@export var block_scene: PackedScene

var current_block: Block = null
var tower_height := 0.0

func _ready() -> void:
    spawn_block()

func spawn_block() -> void:
    current_block = block_scene.instantiate() as Block
    add_child(current_block)
    current_block.position.y = tower_height + 10.0
    current_block.settled.connect(_on_block_settled)

func _on_block_settled() -> void:
    tower_height = max(tower_height, current_block.world_height())
    print('Tower height:', tower_height)
    current_block.settled.disconnect(_on_block_settled)
    spawn_block()
