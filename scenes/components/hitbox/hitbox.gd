@icon("res://scenes/components/hitbox/hitbox.svg")
class_name Hitbox
extends Area2D
## Area that will apply damage to a [Hurtbox] on collision.
##
## Add a child [CollisionShape2D] to define the hitbox area.
## [br]
## Control which [Hurtbox]es to affect with [member collision_layer]
## and [member collision_mask].

## How much damage to apply on collision with a [Hurtbox].
@export_range(0.0, 100.0, 1.0, "or_greater") var damage: float = 10.0
