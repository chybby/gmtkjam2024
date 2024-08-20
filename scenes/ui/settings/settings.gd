extends CanvasLayer

signal closed

@onready var music_volume_slider: HSlider = %MusicVolumeSlider
@onready var sfx_volume_slider: HSlider = %SFXVolumeSlider
@onready var sensitivity_slider: HSlider = %SensitivitySlider
@onready var close_button: Button = %CloseButton
@onready var rotate_minimap_check_box: CheckBox = %RotateMinimapCheckBox

func _ready() -> void:
    music_volume_slider.value_changed.connect(_on_music_volume_slider_value_changed)
    sfx_volume_slider.value_changed.connect(_on_sfx_volume_slider_value_changed)
    sensitivity_slider.value_changed.connect(_on_sensitivity_slider_value_changed)
    sensitivity_slider.value = GlobalState.mouse_sensitivity
    close_button.pressed.connect(_on_close_button_pressed)
    rotate_minimap_check_box.toggled.connect(_on_rotate_minimap_check_box_toggled)
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music_volume_slider.value))
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(sfx_volume_slider.value))

func _on_sensitivity_slider_value_changed(value: float) -> void:
    GlobalState.mouse_sensitivity = value

func _on_close_button_pressed() -> void:
    closed.emit()

func _on_rotate_minimap_check_box_toggled(toggled_on: bool) -> void:
    GlobalState.rotate_minimap = toggled_on

func _on_music_volume_slider_value_changed(value: float) -> void:
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

func _on_sfx_volume_slider_value_changed(value: float) -> void:
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))
