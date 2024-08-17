extends CanvasLayer

@onready var sensitivity_slider: HSlider = %SensitivitySlider
@onready var player: Player = get_tree().get_first_node_in_group("Player")

func _ready() -> void:
    sensitivity_slider.value_changed.connect(_on_sensitivity_slider_value_changed)
    sensitivity_slider.value = player.look_sensitivity

func _on_sensitivity_slider_value_changed(value: float) -> void:
    player.look_sensitivity = value
