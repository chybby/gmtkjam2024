extends CharacterBody2D

@export_range(0.0, 100.0, 0.1, "or_greater", "suffix:px/s") var max_speed: float = 100.0

@onready var health: Health = $Health


func _ready() -> void:
    health.died.connect(on_died)


func _physics_process(_delta: float) -> void:
    var movement_vector = get_movement_vector()
    # TODO: control velocity with a VelocityComponent (Movement?)
    velocity = movement_vector * max_speed
    move_and_slide()


func get_movement_vector() -> Vector2:
    return Input.get_vector("move_left", "move_right", "move_up", "move_down")


func on_died() -> void:
    queue_free()
