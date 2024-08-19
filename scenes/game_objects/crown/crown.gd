extends Area3D

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
    GlobalState.won = true
    GameEvents.emit_game_over()
