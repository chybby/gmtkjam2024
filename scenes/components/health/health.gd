@icon("res://scenes/components/health/health.svg")
class_name Health
extends Node
## Manages the health of an entity.

# Ideas:
# - Shield.
# - Healing over time.
# - Damage over time.


## Emitted when the entity is damaged. [param previous_health] is
## [member current_health] prior to the damage and [param current_health] is
## [member current_health] after the damage.
signal damaged(previous_health: float, current_health: float)

## Emitted when the entity is healed. [param previous_health] is
## [member current_health] prior to the healing and [param current_health] is
## [member current_health] after the healing.
signal healed(previous_health: float, current_health: float)

## Emitted when the entity dies ([member current_health] reaches
## [code]0.0[/code].)
signal died

## Emitted when [member max_health] changes. [param previous_max_health] is
## [member max_health] prior to the change and [param new_max_health] is
## [member max_health] after the change.
signal max_health_changed(previous_max_health: float, new_max_health: float)

## The maximum possible value for [member current_health].
@export_range(0.0, 100.0, 1.0, "or_greater") var max_health: float = 10.0

var _current_health := max_health
## The current health of the entity. A value between [code]0.0[/code] and
## [member max_health].
var current_health: float:
    get:
        return _current_health


## Returns whether the entity is dead ([member current_health] is
## [code]0.0[/code]).
func is_dead() -> bool:
    return _current_health == 0.0


## Damages the entity, reducing [member current_health] by [param value], down
## to a mimimum of [code]0.0[/code].
## [param value] must be positive.
func damage(value: float) -> void:
    assert(value >= 0.0, "Damage value must be positive.")
    var previous_health = _current_health
    _current_health = max(0.0, _current_health - value)
    damaged.emit(previous_health, _current_health)
    if _current_health == 0.0:
        died.emit()


## Heals the entity, increasing [member current_health] by [param value], up to
## a maximum of [param max_health].
## [param value] must be positive.
func heal(value: float) -> void:
    assert(value >= 0.0, "Heal value must be positive.")
    var previous_health = _current_health
    _current_health = min(max_health, _current_health + value)
    healed.emit(previous_health, _current_health)


## Sets [member max_health] to [param value]. [param value] must be positive.
## If [param scale_current_health] is [code]true[/code], the proportion of
## [member current_health] to [member max_health] is maintained. Otherwise,
## [member current_health] remains the same (or is clamped if above the new
## value of [member max_health].)
func set_max_health(value: float, scale_current_health: bool = false) -> void:
    assert(value >= 0.0, "Max health value must be positive.")
    var previous_max_health = max_health
    max_health = value
    if scale_current_health:
        _current_health *= max_health / previous_max_health
    else:
        _current_health = min(max_health, _current_health)

    max_health_changed.emit(previous_max_health, max_health)

    # current_health may now be zero.
    if _current_health == 0.0:
        died.emit()
