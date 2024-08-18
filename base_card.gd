extends TextureButton

class_name base_card

@onready var rarity_image: ColorRect = $MarginContainer/rarity_image
@onready var card_name: Label = $MarginContainer/VBoxContainer/card_name
@onready var description: Label = $MarginContainer/VBoxContainer/MarginContainer/Description


var text
var texture
var rarity

func _ready() -> void:
    if text != null:
        set_card_label(text)
    if rarity != null:
        set_rarity(rarity)
    
func set_card_label(text: String):
    if card_name != null:
        card_name.text = text
    else:
        self.text = text
    
func set_rarity(rarity: int):
    if rarity_image != null:
        match rarity:
            3:
                rarity_image.color = Color(0.392157, 0.584314, 0.929412, 1)
            2:
                rarity_image.color = Color(0.545098, 0, 0.545098, 1)
            1:  
                rarity_image.color = Color(1, 0.54902, 0, 1)
    else:
        self.rarity = rarity
