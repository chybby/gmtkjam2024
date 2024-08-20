extends CanvasLayer
class_name Chance

@export var card_scene: PackedScene

@onready var card_container: HBoxContainer = %CardContainer
@onready var world: World = %World
@onready var player: Player = %Player
@onready var game_over: CanvasLayer = %GameOver

var rarity_weights = {
        3: 0.55, # Common
        2: 0.30, # Rare
        1: 0.15 # Legendary
    }

var card_number := 3
var card_definitions = []
var common_cards = []
var rare_cards = []
var legendary_cards = []

var chances_taken := 0

func _ready():
    load_card_data("res://scenes/ui/chance/cards.json")
    GameEvents.game_over.connect(_on_game_over)

func show_chance_cards():
    clear_container()
    var selected_cards = []
    while selected_cards.size() < card_number:
        var rarity = determine_rarity()
        var random_card = get_random_card(rarity)
        if (random_card not in selected_cards):
            selected_cards.append(random_card)
            print(random_card["name"])

    for card in selected_cards:
        var card_instance = card_scene.instantiate() as Card
        card_instance.set_card(card)

        var bound_callable = Callable(self, "_on_card_pressed").bind(card)
        card_instance.connect("pressed", bound_callable)

        card_container.add_child(card_instance)

    chances_taken += 1
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
                match int(card["rarity"]):
                    3:
                        common_cards.append(card)
                    2:
                        rare_cards.append(card)
                    1:
                        legendary_cards.append(card)
                    _:
                        print("fucky wucky")
        else:
            print("Error parsing JSON: ", json.error_string)
        file.close()
    else:
        print("Error opening file: ", file_path)

func _on_card_pressed(card_data):
    print("Card selected:", card_data["name"])

    process_card_effect(card_data["name"])
    decrement_card_count(card_data)

    hide()
    GameEvents.card_pick_triggered()

func clear_container():
    for child in card_container.get_children():
        child.queue_free()

func _on_cancel_pressed() -> void:
    hide()
    GameEvents.card_pick_triggered()

func process_card_effect(card_name: String) -> void:
     match card_name:
        "More Blocks per Pouch":
            world.added_block_amount += 1
        "Heal Up":
            player.heal()
        "Double Jump!":
            player.jump_number += 1
        "More Chances":
             world.more_chances()
        "Rerolls":
            world.rerolls += 3
        "Bump Lava Down":
            GameEvents.lava_drop_triggered()
        "To the skies!":
            player.teleport()
        "Big Heart":
            player.increase_max_hp()
        "Freeze lava":
            GameEvents.freeze_lava_triggered()
        "Lucky!":
            rarity_weights[3] -= .1
            rarity_weights[2] += .05
            rarity_weights[1] += .05
        "Bombs away!":
            world.start_spawning_bombs()
        "We always bounce back":
            player.increase_knockback()
        "Jump start":
            player.activate_jump_buff()
        "Try Again":
            world.reroll_chances()
        "Refill":
            world.refill()
        "Top up":
            world.added_block_amount += 1
            world.refill()
        "Extra extra":
            card_number += 1
        "Again!?":
            world.repeat_block()
        "Slo-mo":
            player.slomo_buff()

func decrement_card_count(card):
    match int(card["rarity"]):
        3:
            var index = common_cards.find(card)
            card["limit"] -= 1
            if (card["limit"] <= 0):
                common_cards.remove_at(index)
            else:
                common_cards[index] = card
                print(common_cards[index])
        2:
            var index = rare_cards.find(card)
            card["limit"] -= 1
            if (card["limit"] <= 0):
                rare_cards.remove_at(index)
            else:
                rare_cards[index] = card
                print(rare_cards[index])
        1:
            var index = legendary_cards.find(card)
            card["limit"] -= 1
            if (card["limit"] <= 0):
                legendary_cards.remove_at(index)
            else:
                legendary_cards[index] = card
                print(legendary_cards[index])

func _on_game_over():
    game_over.give_chances_taken(chances_taken)
