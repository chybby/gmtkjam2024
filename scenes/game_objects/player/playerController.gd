extends CharacterBody3D
class_name Player

@export var look_sensitivity: float = 0.2
@export var auto_bhop := true
@export var jump_number := 0
@export var nudge_factor := 10

@export var walk_speed := 7.0
@export var sprint_speed := 8.5
@export var ground_accel := 14.0
@export var ground_cap := 10.0
@export var ground_friction := 6.0

@export var jump_velocity := 9.0
@export var bounce_velocity := 20.0
@export var air_cap := 0.85
@export var air_accel := 10.0
@export var air_move_speed := 8.5
@export var gravity_mult := 2.5
@export var terminal_velocity := 70.0

const HEADBOB_MOVE_AMOUNT = 0.06
const HEADBOB_FREQUENCY = 2.4

@onready var head: Node3D = %Head
@onready var hurtbox: Area3D = $Hurtbox
@onready var buff_timer: Timer = %BuffTimer
@onready var camera: Camera3D = %FPCamera
@onready var world_model: Node3D = %WorldModel
@onready var jump_sound: AudioStreamPlayer3D = %JumpSound
@onready var land_sound: AudioStreamPlayer3D = %LandSound
@onready var lava_sizzle_sound: AudioStreamPlayer3D = %LavaSizzleSound

var headbob_time := 0.0
var double_jump := 0
var wish_dir := Vector3.ZERO

var knockback_mult := 1.0
var knockback_ramp := 1.5

var wind_force := Vector3.ZERO
var wind_str := 30.0
var wind_air_str := 2.0

var warning_directions: Array[Vector2] = []

var max_hp := 3
var health := 3

var prev_in_air := false

func look_angle() -> float:
    return rotation.y

func _ready() -> void:
    for child in world_model.find_children("*", "VisualInstance3d"):
        child.set_layer_mask_value(1, false)
        child.set_layer_mask_value(10, true)
    hurtbox.area_entered.connect(_on_hurtbox_entered)
    hurtbox.area_exited.connect(_on_hurtbox_exited)
    buff_timer.timeout.connect(_on_buff_timeout)

func _unhandled_input(event: InputEvent) -> void:
    if GlobalState.intro_mode:
        return

    if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        if event is InputEventMouseMotion:
            rotate_y(-event.relative.x * look_sensitivity / 100)
            camera.rotate_x(-event.relative.y * look_sensitivity / 100)
            camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func get_move_speed() -> float:
        return sprint_speed if Input.is_action_pressed("sprint") else walk_speed

func _process(delta: float) -> void:
    look_sensitivity = GlobalState.mouse_sensitivity
    warning_directions = []
    for area in hurtbox.get_overlapping_areas():
        if area.get_collision_layer_value(5):
            var direction := (area.global_position - global_position).normalized()
            var direction_2d = Vector2(direction.x, direction.z)
            warning_directions.append(direction_2d.rotated(rotation.y))

func _physics_process(delta: float) -> void:
    if GlobalState.intro_mode:
        return

    var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    wish_dir = self.global_transform.basis * Vector3(input_dir.x, 0.,input_dir.y)

    if is_on_floor():
        if prev_in_air:
            land_sound.play()
            prev_in_air = false
        if jump_number > 0:
            double_jump = jump_number
        if Input.is_action_just_pressed("jump") or (auto_bhop and Input.is_action_pressed("jump")):
            jump()
        _handle_ground_physics(delta)
    else:
        if Input.is_action_just_pressed("jump"):
            if double_jump > 0:
                double_jump -= 1
                jump()
        _handle_air_physics(delta)

    move_and_slide()

func _handle_air_physics(delta) -> void:
    self.velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta * gravity_mult
    self.velocity.y = max(self.velocity.y, -terminal_velocity)

    var cur_speed_in_wish_dir = self.velocity.dot(wish_dir)
    var capped_speed = min((air_move_speed * wish_dir).length(), air_cap)
    var add_speed_till_cap = capped_speed - cur_speed_in_wish_dir
    if add_speed_till_cap > 0:
        var accel_speed = air_accel * air_move_speed * delta
        accel_speed = min(accel_speed, add_speed_till_cap)
        self.velocity += accel_speed * wish_dir

    self.velocity += wind_force * delta * wind_air_str

func _handle_ground_physics(delta) -> void:
    var cur_speed_in_wish_dir = self.velocity.dot(wish_dir)
    var add_speed_till_cap = get_move_speed() - cur_speed_in_wish_dir
    if add_speed_till_cap > 0:
        var accel_speed = ground_accel * delta * get_move_speed()
        accel_speed = min(accel_speed, add_speed_till_cap)
        self.velocity += accel_speed * wish_dir

    var control = max(self.velocity.length(), ground_cap)
    var drop = control * ground_friction * delta
    var new_speed = max(self.velocity.length() - drop, 0.0)
    if self.velocity.length() > 0:
        new_speed /= self.velocity.length()
    self.velocity *= new_speed

    self.velocity += wind_force * delta * wind_str

    _headbob_effect(delta)

func _headbob_effect(delta):
    headbob_time += delta * self.velocity.length()
    camera.transform.origin = Vector3(
        cos(headbob_time * HEADBOB_FREQUENCY * 0.5) * HEADBOB_MOVE_AMOUNT,
        sin(headbob_time * HEADBOB_FREQUENCY) * HEADBOB_MOVE_AMOUNT,
        0
    )

func jump():
    prev_in_air = true
    jump_sound.play()
    self.velocity.y = jump_velocity

func change_health(change: int):
    if(health < 0): return
    health += change
    lava_sizzle_sound.play()
    GameEvents.health_changed_triggered()
    if (health <= 0):
        GameEvents.emit_game_over()

func heal():
    if (health < max_hp):
        change_health(1)

func increase_max_hp():
    max_hp += 1
    heal()

func increase_knockback():
    knockback_mult *= knockback_ramp

func knockback_player(vector: Vector3):
    self.velocity += vector * knockback_mult

func apply_wind(vector: Vector3):
    wind_force = vector

func activate_jump_buff():
    jump_velocity += 4.5
    buff_timer.start(20)

func teleport():
    self.position += Vector3(0, 10, 0)
    self.velocity = Vector3.ZERO

func height() -> float:
    var height_value = self.position.y
    return round(height_value * 100) / 100

func _on_hurtbox_entered(area: Area3D) -> void:
    if area.get_collision_layer_value(4):
        change_health(-1)
        self.velocity.y = bounce_velocity * knockback_mult
    elif area.get_collision_layer_value(6):
        # Ice.
        print("slipping")
        ground_friction = 1.0
    elif area.get_collision_layer_value(7):
        # Vines.
        print("slowed")
        walk_speed = 4.5
        sprint_speed = 7

func _on_hurtbox_exited(area: Area3D) -> void:
    if area.get_collision_layer_value(6):
        # Ice.
        print("stop slipping")
        ground_friction = 6.0
    elif area.get_collision_layer_value(7):
        # Vines.
        print("stop slowed")
        walk_speed = 7.0
        sprint_speed = 8.5

func _on_buff_timeout() -> void:
    jump_velocity -= 4.5


func _on_squish_zone_body_entered(body: Node3D) -> void:
    if(body.get_collision_layer_value(1) and is_on_floor()):
        var block = body as Block

        if block and block.falling:
            var open_spot = get_open_spot()
            print(open_spot)
            position = open_spot

func get_open_spot() -> Vector3:
    var directions = [
        Vector3.LEFT,
        Vector3.FORWARD,
        Vector3.RIGHT,
        Vector3.BACK
    ]

    for dir in directions:
        var check_pos = position + dir
        if(is_spot_open(check_pos)):
            return check_pos
    return position + Vector3.UP * 5

func is_spot_open(pos: Vector3) -> bool:
    var space_state = get_world_3d().direct_space_state
    var query = PhysicsRayQueryParameters3D.new()
    query.from = pos + Vector3(0, .5, 0)  # Start the ray above the ground
    query.to = pos + Vector3(0, 2.2, 0)  # End the ray below the ground
    query.collision_mask = 1  # Adjust this mask to the relevant collision layer

    var result = space_state.intersect_ray(query)
    print(result)
    return result.size() <= 0
