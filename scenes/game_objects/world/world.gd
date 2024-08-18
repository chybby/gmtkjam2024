extends Node3D

@export var block_scenes: Array[PackedScene]
@export var block_pickup_scene: PackedScene
@export var bomb_scene: PackedScene
@export var blocks_remaining := -1
@export var added_block_amount := 10

@onready var bomb_timer: Timer = %BombTimer

var current_block: Block = null
var tower_height := 0.0
var limited_blocks := false
var spawning_blocks := false
var last_spawned_pickup := 0.0
var pickup_frequency := 5


func _ready() -> void:
    if(blocks_remaining > 0):
        limited_blocks = true
        GameEvents.block_pickup_picked_up.connect(add_blocks)
    spawn_block()
    bomb_timer.timeout.connect(_on_bomb_timer_timeout)

func spawn_block() -> void:
    if(limited_blocks):
        if(blocks_remaining <= 0):
            spawning_blocks = false
            return
        else:
            blocks_remaining -= 1

    spawning_blocks = true

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

    if(limited_blocks):
        if (last_spawned_pickup - tower_height < pickup_frequency):
            spawn_pickup()

    print('Tower height:', tower_height)
    current_block.settled.disconnect(_on_block_settled)
    spawn_block()

func add_blocks() -> void:
    if(limited_blocks):
        blocks_remaining += added_block_amount
        if(!spawning_blocks):
            spawn_block()

func spawn_pickup() -> void:
    last_spawned_pickup += pickup_frequency
    var pickup = block_pickup_scene.instantiate() as Pickup
    add_child(pickup)
    var random_x = randi_range(-5, 4) + 0.5
    var random_z = randi_range(-5, 4) + 0.5
    pickup.position = Vector3(random_x, last_spawned_pickup, random_z)

func _on_bomb_timer_timeout() -> void:
    var bomb = bomb_scene.instantiate() as Node3D
    add_child(bomb)
    var random_x = randi_range(-5, 4) + 0.5
    var random_z = randi_range(-5, 4) + 0.5
    bomb.position = Vector3(random_x, tower_height + 10.0, random_z)
