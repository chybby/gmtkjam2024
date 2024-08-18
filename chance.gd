extends CanvasLayer
class_name Chance

@onready var card_container: HBoxContainer = $Control/Panel/CardContainer
@export var card_base : PackedScene

var card_number := 3
var card_definitions = []
var common_cards = []
var rare_cards = []
var legendary_cards = []

func _ready():
    load_card_data("res://scenes/ui/chance/cards.json")

func show_chance_cards():
    clear_container()
    var selected_cards = []
    while selected_cards.size() < 3:
        var rarity = determine_rarity()
        var random_card = get_random_card(rarity)
        if(random_card not in selected_cards):
            selected_cards.append(random_card)
            print(random_card["name"])
            
    for card in selected_cards:
        var card_instance = card_base.instantiate() as base_card
        card_instance.set_card_label(card["name"])
        card_instance.set_rarity(card["rarity"])
        
        var bound_callable = Callable(self, "_on_card_pressed").bind(card)
        card_instance.connect("pressed", bound_callable)
        
        card_container.add_child(card_instance)
        
    show()

func get_random_card(rarity: int):
    match rarity:
        3:
            return common_cards[randi() % common_cards.size()]
        2:
            return rare_cards[randi() % rare_cards.size()]
        1:
            return legendary_cards[randi() % legendary_cards.size()]
        _:
            return common_cards[randi() % common_cards.size()]
    
func determine_rarity() -> int:
    var rarity_weights = {
        3: 0.55,  # Common
        2: 0.30,  # Rare
        1: 0.15   # Legendary
    }
    
    var random_value = randf()
    var cumulative_weight = 0.0
    
    for rarity in rarity_weights.keys():
        cumulative_weight += rarity_weights[rarity]
        if random_value < cumulative_weight:
            return rarity
            
    return 4
    
func load_card_data(file_path: String) -> void:
    var file = FileAccess.open(file_path, FileAccess.READ)
    if file:
        var data = file.get_as_text()
        var json = JSON.new()
        var error = json.parse(data)
        if error == OK:
            card_definitions = json.data["cards"]
            for card in card_definitions:
                print(card["rarity"])
                match int(card["rarity"]):
                    3:
                        common_cards.append(card)
                        print("common appended")
                    2:
                        rare_cards.append(card)
                        print("rare appended")
                    1:
                        legendary_cards.append(card)
                        print("legendary appended")
                    _:
                        print("fucky wucky")  
        else:
            print("Error parsing JSON: ", json.error_string)
        file.close()
    else:
        print("Error opening file: ", file_path)
        
func _on_card_pressed(card_data):
    print("Card selected:" , card_data["name"])
    
    hide()
    GameEvents.card_pick_triggered()
    
func clear_container():
    for child in card_container.get_children():
        child.queue_free()


func _on_cancel_pressed() -> void:
    hide()
    GameEvents.card_pick_triggered()
