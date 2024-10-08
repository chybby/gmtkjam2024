extends RigidBody3D

@onready var lifetime_timer: Timer = %LifetimeTimer

func _ready() -> void:
    lifetime_timer.timeout.connect(_on_lifetime_timer_timeout)

func _physics_process(delta: float) -> void:
    if not freeze and linear_velocity.is_zero_approx():
        freeze = true
        position = (position - Vector3(0, 0.3, 0)).round()
        if not test_move(transform, Vector3(0, -1, 0)):
            position.y -= 1

func _on_lifetime_timer_timeout() -> void:
    queue_free()
