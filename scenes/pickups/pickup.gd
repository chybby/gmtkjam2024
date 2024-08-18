extends RigidBody3D
class_name Pickup

func _physics_process(delta: float) -> void:
    if not freeze and linear_velocity.is_zero_approx():
        freeze = true
        position = position.round()

func _on_body_entered(body: Node):
    if body.is_in_group("Player"):
        GameEvents.block_pickup_triggered()
        queue_free()
