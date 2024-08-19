extends RigidBody3D

@export var explosion_push_strength := 30.0

@onready var explosion_particles: GPUParticles3D = %ExplosionParticles
@onready var timer: Timer = %Timer
@onready var explosion_area: Area3D = $ExplosionArea
@onready var model: Node3D = %Model
@onready var centre: Node3D = %Centre

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    timer.timeout.connect(_on_timer_timeout)

func _on_body_entered(body: Node) -> void:
    if timer.is_stopped():
        timer.start()
        model.play_exploding()

func _physics_process(delta: float) -> void:
    if not freeze and linear_velocity.is_zero_approx():
        freeze = true
        position = position.round()

func _on_timer_timeout() -> void:
    explosion_particles.emitting = true
    model.visible = false
    var caught_in_explosion := explosion_area.get_overlapping_bodies()
    if caught_in_explosion.size() != 0:
        var player := caught_in_explosion[0] as Player
        var vector := (player.global_position + Vector3.UP * 0.9) - centre.global_position
        var direction = vector.normalized()
        var distance = vector.length()

        var strength := 0.0
        if distance < 0.1:
            strength = explosion_push_strength
        elif distance <= 3.0:
            var gradient = -1/(3 - 0.1)
            var y_intercept = 1 + (0.1 * gradient)
            strength = explosion_push_strength * (gradient * distance + y_intercept)
        player.knockback_player(direction * strength)
    await explosion_particles.finished
    queue_free()
