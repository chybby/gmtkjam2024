extends Area3D

func _on_body_entered(body: Node):
    print(body.name)
    if body.is_in_group("Player"):
        print("Chance triggered")
        GameEvents.chance_pickup_triggered()
        queue_free()
