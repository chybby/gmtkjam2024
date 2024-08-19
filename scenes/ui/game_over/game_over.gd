extends CanvasLayer

signal try_again(chaos_mode: bool)

@onready var try_again_button: Button = %TryAgainButton
@onready var chaos_mode_button: Button = %ChaosModeButton

func _ready() -> void:
    try_again_button.pressed.connect(_on_try_again_button_pressed)
    chaos_mode_button.pressed.connect(_on_chaos_mode_button_pressed)

func allow_chaos_mode() -> void:
    chaos_mode_button.visible = true

func _on_try_again_button_pressed() -> void:
    try_again.emit(false)

func _on_chaos_mode_button_pressed() -> void:
    try_again.emit(true)
