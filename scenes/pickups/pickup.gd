extends RigidBody3D
class_name Pickup

@onready var pickup_sound: AudioStreamPlayer = $PickupSound

func _physics_process(delta: float) -> void:
    if not freeze and linear_velocity.is_zero_approx():
        freeze = true
        position = position.round()

func _on_body_entered(body: Node3D):
    print(body.name)
    if body.is_in_group("Player"):
        GameEvents.block_pickup_triggered()
        queue_free()

func _on_pickup_area_area_entered(area: Area3D) -> void:
    print(area.name)
    if area.get_collision_layer_value(4):
        queue_free()
