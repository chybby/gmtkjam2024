extends Button

class_name Card

@onready var description_label: Label = %DescriptionLabel
@onready var name_label: Label = %NameLabel
@onready var style_box: StyleBoxFlat = get_theme_stylebox("normal").duplicate()
@onready var hovered_style_box: StyleBoxFlat = get_theme_stylebox("hover").duplicate()

@export var rare_colour: Color
@export var darker_rare_colour: Color
@export var epic_colour: Color
@export var darker_epic_colour: Color
@export var legendary_colour: Color
@export var darker_legendary_colour: Color

var card

func _ready() -> void:
    set_card_name(card["name"])
    set_card_description(card["description"])
    set_rarity(card["rarity"])

    add_theme_stylebox_override("normal", style_box)
    add_theme_stylebox_override("hover", hovered_style_box)
    add_theme_stylebox_override("pressed", hovered_style_box)

func set_card(card):
    self.card = card

func set_card_name(text: String):
    name_label.text = text

func set_card_description(text: String):
    description_label.text = text

func set_rarity(rarity: int):
    match rarity:
        1:
            style_box.bg_color = legendary_colour
            hovered_style_box.bg_color = darker_legendary_colour
        2:
            style_box.bg_color = epic_colour
            hovered_style_box.bg_color = darker_epic_colour
        3:
            style_box.bg_color = rare_colour
            hovered_style_box.bg_color = darker_rare_colour
