extends Node3D
class_name World

@export var block_scenes: Array[PackedScene]
@export var block_pickup_scene: PackedScene
@export var chance_pickup_scene: PackedScene
@export var snow_patch_scene: PackedScene
@export var bomb_scene: PackedScene
@export var blocks_remaining := -1
@export var added_block_amount := 5

@onready var bomb_timer: Timer = %BombTimer
@onready var snow_timer: Timer = %SnowTimer

var current_block: Block = null
var tower_height := 0.0
var limited_blocks := false
var spawning_blocks := false

var last_spawned_pickup := 0.5
var pickup_frequency := 5

var last_spawned_chance := 0.0
var chance_frequency := 7

var rerolls := 5
var block_raycasts := []


func _ready() -> void:
    if (blocks_remaining > 0):
        limited_blocks = true
        GameEvents.block_pickup_picked_up.connect(add_blocks)
    spawn_block()
    bomb_timer.timeout.connect(_on_bomb_timer_timeout)
    snow_timer.timeout.connect(_on_snow_timer_timeout)
    for x in 10:
        block_raycasts.append([])
        for z in 10:
            var query := PhysicsRayQueryParameters3D.create(Vector3(x - 4.5, 100.0, z - 4.5), Vector3(x - 4.5, 0.0, z - 4.5))
            query.collision_mask = 1 | 8
            query.collide_with_areas = true
            block_raycasts[block_raycasts.size() - 1].append(query)

    for x in 10:
        block_raycasts.append([])
        for z in 10:
            var query := PhysicsRayQueryParameters3D.create(Vector3(x - 4.5, 100.0, z - 4.5), Vector3(x - 4.5, 0.0, z - 4.5))
            query.collision_mask = 1 | 8
            query.collide_with_areas = true
            block_raycasts[block_raycasts.size() - 1].append(query)

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("reroll"):
        _reroll_block()

func _reroll_block() -> void:
    if (rerolls > 0):
        rerolls -= 1
        current_block.queue_free()
        if (limited_blocks):
            blocks_remaining += 1
        spawn_block()

func spawn_block() -> void:
    if (limited_blocks):
        if (blocks_remaining <= 0):
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

    if (limited_blocks):
        #if (last_spawned_pickup - tower_height < pickup_frequency):
        #if blocks_remaining == 0:
            spawn_pickup()

    if (last_spawned_chance - tower_height < chance_frequency):
        spawn_chance()

    print('Tower height:', tower_height)
    current_block.settled.disconnect(_on_block_settled)
    spawn_block()

func add_blocks() -> void:
    if (limited_blocks):
        blocks_remaining += added_block_amount
        if (!spawning_blocks):
            spawn_block()

func spawn_pickup() -> void:
    last_spawned_pickup += pickup_frequency
    var pickup = block_pickup_scene.instantiate() as Pickup
    add_child(pickup)

    pickup.position = get_valid_drop_position()
    

func spawn_chance() -> void:
    last_spawned_chance += chance_frequency
    var chance = chance_pickup_scene.instantiate() as Node3D
    _spawn_object_at_height(last_spawned_chance, chance)

func _on_bomb_timer_timeout() -> void:
    var bomb = bomb_scene.instantiate() as Node3D
    _spawn_object_at_height(tower_height + 10.0, bomb)
    
func _on_snow_timer_timeout() -> void:
    var snow = snow_patch_scene.instantiate() as Node3D
    _spawn_object_at_height(tower_height + 10.0, snow)
    
func more_chances() -> void:
    chance_frequency -= 1
    
func start_spawning_bombs() -> void:
    bomb_timer.start()

func reroll_chances() -> void:
    var chance = chance_pickup_scene.instantiate() as Node3D
    add_child(chance)
    chance.position = %Player.position + Vector3(0,2,0)

func _spawn_object_at_height(height: float, obj: Node3D):
    add_child(obj)
    var random_x = randi_range(-5, 4)
    var random_z = randi_range(-5, 4)
    obj.position = Vector3(random_x, height, random_z)

func get_valid_drop_position() -> Vector3:
    var options = []
    var space_state = get_world_3d().direct_space_state
    for x in 10:
        for z in 10:
            var result := space_state.intersect_ray(block_raycasts[x][z])
            print(result['collider'].collision_mask)
            if result['collider'].collision_mask & 1:
                options.append(Vector3(x, last_spawned_pickup, z))
    return options.pick_random() - Vector3(5.0, 0, 5.0)
