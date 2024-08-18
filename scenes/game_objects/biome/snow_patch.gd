extends RigidBody3D
class_name Snow_Patch

@onready var lifetime_timer: Timer = %LifetimeTimer

var is_in_block = false

func _ready() -> void:
    lifetime_timer.timeout.connect(_on_lifetime_timer_timeout)

func _on_body_entered(body: Node):
    if body.is_in_group("Player"):
        is_in_block = true
        GameEvents.ice_patch_entered()

func _on_body_exited(body: Node) -> void:
    if body.is_in_group("Player"):
        is_in_block = false
        GameEvents.ice_patch_exited()


func _on_lifetime_timer_timeout() -> void:
    if(is_in_block):
        GameEvents.ice_patch_exited()
        
    queue_free()
    
