extends CanvasLayer

signal closed

@onready var sensitivity_slider: HSlider = %SensitivitySlider
@onready var close_button: Button = %CloseButton
@onready var rotate_minimap_check_box: CheckBox = %RotateMinimapCheckBox

func _ready() -> void:
    sensitivity_slider.value_changed.connect(_on_sensitivity_slider_value_changed)
    sensitivity_slider.value = GlobalState.mouse_sensitivity
    close_button.pressed.connect(_on_close_button_pressed)
    rotate_minimap_check_box.toggled.connect(_on_rotate_minimap_check_box_toggled)

func _on_sensitivity_slider_value_changed(value: float) -> void:
    GlobalState.mouse_sensitivity = value

func _on_close_button_pressed() -> void:
    closed.emit()

func _on_rotate_minimap_check_box_toggled(toggled_on: bool) -> void:
    GlobalState.rotate_minimap = toggled_on
