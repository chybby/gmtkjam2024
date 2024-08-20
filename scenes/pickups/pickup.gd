extends RigidBody3D
class_name Pickup

func _physics_process(delta: float) -> void:
    if not freeze and linear_velocity.is_zero_approx():
        freeze = true
        position = (position - Vector3(0, 0.3, 0)).round()
        if not test_move(transform, Vector3(0, -1, 0)):
            position.y -= 1

func _on_body_entered(body: Node3D):
    if body.is_in_group("Player"):
        GameEvents.block_pickup_triggered()
        queue_free()

func _on_pickup_area_area_entered(area: Area3D) -> void:
    if area.get_collision_layer_value(4):
        queue_free()
