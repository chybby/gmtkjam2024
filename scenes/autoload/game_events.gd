extends Node

signal block_pickup_picked_up

func block_pickup_triggered() -> void:
    block_pickup_picked_up.emit()
