extends Node3D
class_name Lava

@onready var timer: Timer = $Timer

@export var speed := 0.1
@export var delay := 60.0
@export var discrete := false
@export var interval := 30.0

var rising := false

func _ready() -> void:
    timer.start(delay)
    timer.timeout.connect(_on_timer_timeout)
    GameEvents.drop_lava.connect(_on_drop_lava)
    GameEvents.freeze_lava.connect(_on_freeze_lava)
    if(discrete):
        position.y = -0.4

func _physics_process(delta: float) -> void:
    if rising and not discrete:
        position.y += delta * speed

func _on_timer_timeout() -> void:
    if(!discrete):
        rising = true
    else:
        position.y += 1
        timer.start(interval)

func _on_drop_lava() -> void:
    position.y -= 3

func _on_freeze_lava() -> void:
    if(!discrete):
        rising = false
        timer.start(5)
    else:
        timer.start(timer.time_left + 5)

func time_left() -> float:
    return timer.time_left
