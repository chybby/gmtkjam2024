extends CharacterBody3D
class_name Player

signal died

@export var look_sensitivity: float = 0.5
@export var auto_bhop := true
@export var jump_number := 1

@export var walk_speed := 7.0
@export var sprint_speed := 8.5
@export var ground_accel := 14.0
@export var ground_cap := 10.0
@export var ground_friction := 6.0

@export var jump_velocity := 7.0
@export var bounce_velocity := 30.0
@export var air_cap := 0.85
@export var air_accel := 10.0
@export var air_move_speed := 8.5
@export var gravity_mult := 1.2
@export var terminal_velocity := 70.0


const HEADBOB_MOVE_AMOUNT = 0.06
const HEADBOB_FREQUENCY = 2.4

@onready var head: Node3D = %Head
@onready var hurtbox: Area3D = $Hurtbox

var headbob_time := 0.0
var double_jump := 0
var wish_dir := Vector3.ZERO

var health := 3

func look_angle() -> float:
    return rotation.y

func _ready() -> void:
    for child in %WorldModel.find_children("*", "VisualInstance3d"):
        child.set_layer_mask_value(1, false)
        child.set_layer_mask_value(10, true)
    hurtbox.area_entered.connect(_on_lava_entered)

func _unhandled_input(event: InputEvent) -> void:
    if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        if event is InputEventMouseMotion:
            rotate_y(-event.relative.x * look_sensitivity / 100)
            %FPCamera.rotate_x(-event.relative.y * look_sensitivity / 100)
            %FPCamera.rotation.x = clamp(%FPCamera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func get_move_speed() -> float:
        return sprint_speed if Input.is_action_pressed("sprint") else walk_speed

func _physics_process(delta: float) -> void:
    var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    wish_dir = self.global_transform.basis * Vector3(input_dir.x, 0.,input_dir.y)

    if is_on_floor():
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

    if (wish_dir.length() < 0.1):
        var deceleration = 0.96
        self.velocity.x *= deceleration
        self.velocity.z *= deceleration

    else:
        var cur_speed_in_wish_dir = self.velocity.dot(wish_dir)
        var capped_speed = min((air_move_speed * wish_dir).length(), air_cap)
        var add_speed_till_cap = capped_speed - cur_speed_in_wish_dir
        if add_speed_till_cap > 0:
            var accel_speed = air_accel * air_move_speed * delta
            accel_speed = min(accel_speed, add_speed_till_cap)
            self.velocity += accel_speed * wish_dir


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

    _headbob_effect(delta)

func _headbob_effect(delta):
    headbob_time += delta * self.velocity.length()
    %FPCamera.transform.origin = Vector3(
        cos(headbob_time * HEADBOB_FREQUENCY * 0.5) * HEADBOB_MOVE_AMOUNT,
        sin(headbob_time * HEADBOB_FREQUENCY) * HEADBOB_MOVE_AMOUNT,
        0
    )

func jump():
    self.velocity.y = jump_velocity

func _on_lava_entered(area: Area3D) -> void:
    if health == 1:
        died.emit()
    else:
        health -= 1
        self.velocity.y = bounce_velocity
