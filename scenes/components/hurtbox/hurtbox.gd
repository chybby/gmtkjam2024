@tool
@icon("res://scenes/components/hurtbox/hurtbox.svg")
class_name Hurtbox
extends Area2D
## Monitors for [Hitbox]es and applies damage to the linked [Health] on
## collision.
##
## Add a child [CollisionShape2D] to define the monitored area.
## [br]
## Control which [Hitbox]es to monitor with [member collision_layer]
## and [member collision_mask].

## The [Health] to apply damage to.
@export var health: Health:
    set(value):
        health = value
        update_configuration_warnings()


func _ready() -> void:
    area_entered.connect(_on_area_entered)


func _get_configuration_warnings() -> PackedStringArray:
    var warnings = PackedStringArray()

    if health == null:
        warnings.append("Health is not assigned, so this hurtbox won't do any damage.")

    return warnings


func _on_area_entered(other_area: Area2D) -> void:
    if not other_area is Hitbox:
        return

    if health == null:
        push_warning("Hurtbox not connected to a Health instance.")
        return

    var hitbox = other_area as Hitbox
    health.damage(hitbox.damage)
