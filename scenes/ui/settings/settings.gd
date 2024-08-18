extends CanvasLayer

signal closed

@onready var sensitivity_slider: HSlider = %SensitivitySlider
@onready var close_button: Button = %CloseButton

func _ready() -> void:
    sensitivity_slider.value_changed.connect(_on_sensitivity_slider_value_changed)
    sensitivity_slider.value = GlobalState.mouse_sensitivity
    close_button.pressed.connect(_on_close_button_pressed)

func _on_sensitivity_slider_value_changed(value: float) -> void:
    GlobalState.mouse_sensitivity = value

func _on_close_button_pressed() -> void:
    closed.emit()
