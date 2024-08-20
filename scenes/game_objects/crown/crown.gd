extends Area3D

@onready var block_pickup_sound: AudioStreamPlayer = %BlockPickupSound

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
    block_pickup_sound.play()
    GlobalState.won = true
    GameEvents.emit_game_over()
