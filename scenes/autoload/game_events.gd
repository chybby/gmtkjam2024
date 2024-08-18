extends Node

signal block_pickup_picked_up
signal card_selected
signal chance_picked_up
signal drop_lava

func block_pickup_triggered() -> void:
    block_pickup_picked_up.emit()

func card_pick_triggered() -> void:
    card_selected.emit()

func chance_pickup_triggered() -> void:
    chance_picked_up.emit()

func lava_drop_triggered() -> void:
    drop_lava.emit()
