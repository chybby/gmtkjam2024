class_name WeightedTable
extends RefCounted
## A data structure used for randomly picking an item from a set of items where
## each item has an associated weight that affects how often it is picked.
##
## Usage:
## [codeblock]
## var weighted_table := WeightedTable.new()
## weighted_table.add("a", 1.0)
## weighted_table.add("b", 2.0)
## weighted_table.add("c", 10.0)
## var random_item = weighted_table.pick()
## [/codeblock]


# Maps from item (Variant) to weight (float).
var _items := {}

# The total weight of all items.
var _total_weight: float = 0.0


## Adds [param item] to the stored set of items. A higher value of
## [param weight] will mean that this item will be picked more frequently by
## [method pick].
## [param weight] must be greater than zero.
## If [param item] is already in the set of items, its weight will be updated.
func add(item: Variant, weight: float) -> void:
    _total_weight -= _items.get(item, 0)
    _items[item] = weight
    _total_weight += weight


## Removes [param item] from the stored set of items.
## Returns [code]true[/code] if the given item existed, otherwise
## [code]false[/code].
func erase(item: Variant) -> bool:
    _total_weight -= _items.get(item, 0)
    return _items.erase(item)


## Returns the number of stored items.
func size() -> int:
    return _items.size()


## Returns [code]true[/code] if the stored set of items is empty.
func is_empty() -> bool:
    return size() == 0


## Randomly picks an item from the stored set of items according to the weight
## distribution.
## Returns [code]null[/code] if the stored set of items is empty.
func pick() -> Variant:
    var accumulated_weight: float = 0.0;
    var random_value = randf_range(0.0, _total_weight)
    for item in _items:
        accumulated_weight += _items[item]
        if accumulated_weight >= random_value:
            return item

    return null


## Creates and returns a new copy of the table.
func duplicate() -> WeightedTable:
    var new_weighted_table = WeightedTable.new()
    new_weighted_table._items = _items.duplicate()
    new_weighted_table._total_weight = _total_weight
    return new_weighted_table
