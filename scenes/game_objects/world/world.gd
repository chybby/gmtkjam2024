extends Node3D
class_name World

@export var block_scenes: Array[PackedScene]
@export var block_pickup_scene: PackedScene
@export var chance_pickup_scene: PackedScene
@export var snow_patch_scene: PackedScene
@export var vines_patch_scene: PackedScene
@export var bomb_scene: PackedScene
@export var blocks_remaining := -1
@export var added_block_amount := 5

@onready var bomb_timer: Timer = %BombTimer
@onready var snow_timer: Timer = %SnowTimer
@onready var vines_timer: Timer = %VinesTimer
@onready var wind_start_timer: Timer = %WindStartTimer
@onready var wind_stop_timer: Timer = %WindStopTimer
@onready var particle_holder: Node3D = $ParticleHolder
@onready var falling_leaf_particles: GPUParticles3D = %FallingLeafParticles
@onready var falling_snow_particles: GPUParticles3D = %FallingSnowParticles

@onready var player: Player = %Player

var current_block: Block = null
var tower_height := 0.0
var limited_blocks := false
var spawning_vines := false
var spawning_snow := false
var spawning_wind := false
var low_grav := false

var blowing_wind := false

var wind_direction := Vector3.RIGHT

var last_spawned_pickup := 0.5
var pickup_frequency := 5

var last_spawned_chance := 0.0
var chance_frequency := 7

var rerolls := 5
var block_raycasts := []

var no_blocks_hint_shown := false


func _ready() -> void:
    if (blocks_remaining > 0):
        limited_blocks = true
        GameEvents.block_pickup_picked_up.connect(add_blocks)
    bomb_timer.timeout.connect(_on_bomb_timer_timeout)
    snow_timer.timeout.connect(_on_snow_timer_timeout)
    vines_timer.timeout.connect(_on_vines_timer_timeout)
    wind_start_timer.timeout.connect(_on_wind_start_timeout)
    wind_stop_timer.timeout.connect(_on_wind_stop_timeout)

    setup_ray_array()

const VINE_BIOME_START := 10.0
const SNOW_BIOME_START := 20.0
const WIND_BIOME_START := 30.0
const SPACE_BIOME_START := 40.0

var vines_hint_shown := false
var snow_hint_shown := false
var wind_hint_shown := false
var space_hint_shown := false

func _physics_process(delta: float) -> void:
    if current_block == null and blocks_remaining > 0:
        spawn_block()

    var cur_height = player.height()
    if cur_height >= VINE_BIOME_START and not spawning_vines:
        start_spawning_vines()
        if not vines_hint_shown:
            GameEvents.show_hint("Don't get your feet tangled up in the falling vines!")
            vines_hint_shown = true
    elif cur_height < VINE_BIOME_START and spawning_vines:
        stop_spawning_vines()

    if cur_height >= SNOW_BIOME_START and not spawning_snow:
        start_spawning_snow()
        if not snow_hint_shown:
            GameEvents.show_hint("Brrr, it's getting chilly up here.\nMind the slippery ice!")
            snow_hint_shown = true
    elif cur_height < SNOW_BIOME_START and spawning_snow:
        stop_spawning_snow()

    if cur_height >= WIND_BIOME_START and not spawning_wind:
        start_spawning_wind()
        if not wind_hint_shown:
            GameEvents.show_hint("These winds are strong enough to blow you away!")
            wind_hint_shown = true
    elif cur_height < WIND_BIOME_START and spawning_wind:
        stop_spawning_wind()

    if cur_height >= SPACE_BIOME_START and not low_grav:
        start_low_grav()
        if not space_hint_shown:
            GameEvents.show_hint("You're high enough to start escaping the pull of gravity!")
            space_hint_shown = true
    elif cur_height < SPACE_BIOME_START and low_grav:
        stop_low_grav()

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("reroll"):
        _reroll_block()

func _reroll_block() -> void:
    if (rerolls > 0):
        rerolls -= 1
        current_block.queue_free()
        current_block = null

func spawn_block() -> void:
    current_block = block_scenes.pick_random().instantiate() as Block
    add_child(current_block)
    current_block.position.y = tower_height + 10.0

    current_block.rotate_x(randi_range(0, 3) * (PI / 2))
    current_block.rotate_y(randi_range(0, 3) * (PI / 2))
    current_block.rotate_z(randi_range(0, 3) * (PI / 2))

    current_block.settled.connect(_on_block_settled)

func _on_block_settled() -> void:
    tower_height = max(tower_height, current_block.world_height())

    if (limited_blocks):
        blocks_remaining -= 1
        if blocks_remaining == 0:
            if not no_blocks_hint_shown:
                GameEvents.show_hint("You've run out of blocks!\nPick up the pouch that dropped from above.")
                no_blocks_hint_shown = true
            spawn_pickup()

    if (last_spawned_chance - tower_height < chance_frequency):
        spawn_chance()

    print('Tower height:', tower_height)
    current_block.settled.disconnect(_on_block_settled)
    current_block = null

func add_blocks() -> void:
    if (limited_blocks):
        blocks_remaining += added_block_amount

func spawn_pickup() -> void:
    last_spawned_pickup = player.position.y + 10.0
    var pickup = block_pickup_scene.instantiate() as Pickup

    pickup.position = get_valid_drop_position()
    pickup.tree_exiting.connect(_on_pickup_destroyed)
    add_child.call_deferred(pickup)

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

func _on_vines_timer_timeout() -> void:
    var vines = vines_patch_scene.instantiate() as Node3D
    add_child(vines)
    vines.position = get_valid_drop_position()

func _on_wind_start_timeout() -> void:
    blowing_wind = true
    wind_direction = get_random_direction()
    player.apply_wind(wind_direction)
    wind_stop_timer.start()
    print("blowing ", wind_direction)

func _on_wind_stop_timeout() -> void:
    blowing_wind = false
    player.apply_wind(Vector3.ZERO)
    if(spawning_wind):
        wind_start_timer.start()
    print("out of breath")

func more_chances() -> void:
    chance_frequency -= 1

func refill() -> void:
    blocks_remaining += added_block_amount

func start_spawning_bombs() -> void:
    bomb_timer.start()

func start_spawning_vines() -> void:
    spawning_vines = true
    vines_timer.start()
    falling_leaf_particles.emitting = true

func stop_spawning_vines() -> void:
    spawning_vines = false
    vines_timer.stop()
    falling_leaf_particles.emitting = false

func start_spawning_snow() -> void:
    spawning_snow = true
    snow_timer.start()
    falling_snow_particles.emitting = true

func stop_spawning_snow() -> void:
    spawning_snow = false
    snow_timer.stop()
    falling_snow_particles.emitting = false

func start_spawning_wind() -> void:
    spawning_wind = true
    wind_start_timer.start()

func stop_spawning_wind() -> void:
    spawning_wind = false
    wind_start_timer.stop()

func start_low_grav() -> void:
    low_grav = true
    player.gravity_mult *= .5

func stop_low_grav() -> void:
    low_grav = false
    player.gravity_mult *= 2

func reroll_chances() -> void:
    var chance = chance_pickup_scene.instantiate() as Node3D
    add_child(chance)
    chance.position = %Player.position + Vector3(0,2,0)

func _on_pickup_destroyed() -> void:
    if(blocks_remaining == 0):
        spawn_pickup()

func get_random_direction() -> Vector3:
    var directions = [
        Vector3(1, 0, 0),    # Right (positive X direction)
        Vector3(-1, 0, 0),   # Left (negative X direction)
        Vector3(0, 0, 1),    # Forward (positive Z direction)
        Vector3(0, 0, -1)    # Backward (negative Z direction)
    ]

    return directions.pick_random()

func _spawn_object_at_height(height: float, obj: Node3D):
    add_child(obj)
    var random_x = randi_range(-5, 4)
    var random_z = randi_range(-5, 4)
    obj.position = Vector3(random_x, height, random_z)

func setup_ray_array() -> void:
    for x in 10:
        block_raycasts.append([])
        for z in 10:
            var query := PhysicsRayQueryParameters3D.create(Vector3(x - 4.5, 100.0, z - 4.5), Vector3(x - 4.5, 0.0, z - 4.5))
            query.collision_mask = 1 | 8
            query.collide_with_areas = true
            block_raycasts[block_raycasts.size() - 1].append(query)

func get_valid_drop_position() -> Vector3:
    var options = []
    var space_state = get_world_3d().direct_space_state
    for x in 10:
        for z in 10:
            var result := space_state.intersect_ray(block_raycasts[x][z])
            if result['collider'].collision_mask & 1:
                options.append(Vector3(x, last_spawned_pickup, z))
    if options.size() == 0:
        return Vector3(0.0, last_spawned_pickup, 0.0)
    return options.pick_random() - Vector3(5.0, 0, 5.0)
