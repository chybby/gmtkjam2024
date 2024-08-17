extends Area3D

class_name Pickup

func _on_body_entered(body: Node):
    print(body.name)
    if body.is_in_group("Player"):
        print("Pickup triggered")
        GameEvents.block_pickup_triggered()
        queue_free()
