extends TextureButton

class_name base_card

@onready var rarity_image: ColorRect = $MarginContainer/rarity_image
@onready var description: Label = $MarginContainer/VBoxContainer/MarginContainer/Description
@onready var card_name: Label = $MarginContainer/VBoxContainer/MarginContainer2/card_name

var card

func _ready() -> void:
        set_card_label(card["name"])
        set_card_description(card["description"])
        set_rarity(card["rarity"])
        
func set_card(card):
    self.card = card
    
func set_card_label(text: String):
    card_name.text = text
  

func set_card_description(text: String):
    description.text = text
    
func set_rarity(rarity: int):
    if rarity_image != null:
        match rarity:
            3:
                rarity_image.color = Color(0.392157, 0.584314, 0.929412, 1)
            2:
                rarity_image.color = Color(0.545098, 0, 0.545098, 1)
            1:  
                rarity_image.color = Color(1, 0.54902, 0, 1)
