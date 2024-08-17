extends Node3D

@onready var timer: Timer = $Timer

@export var speed := 0.1
@export var delay := 60.0

var rising := false

func _ready() -> void:
    timer.start(delay)
    timer.timeout.connect(_on_timer_timeout)

func _physics_process(delta: float) -> void:
    if rising:
        position.y += delta * speed

func _on_timer_timeout() -> void:
    rising = true
