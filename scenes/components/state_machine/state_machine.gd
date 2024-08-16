@tool
@icon("res://scenes/components/state_machine/state_machine.svg")
class_name StateMachine
extends Node
## A finite state machine (FSM) that manages transitioning between different
## child [State]s.
##
## Add children to this node with scripts that extend [State].
## When a state is running, it will receive [method Node._process] and
## [method Node._physics_process] callbacks, otherwise those callbacks will be
## disabled.

## Emitted when the state machine moves from [param old_state] to
## [param new_state].
signal state_changed(old_state: State, new_state: State)

## The [State] to enter initially.
@export var initial_state: State = null:
    set(value):
        initial_state = value
        update_configuration_warnings()

# Dictionary from state name (String) to state (State).
var _states = {}

@onready var _current_state: State = initial_state
## The currently running [State].
var current_state: State:
    get:
        return _current_state


func _ready() -> void:
    # Update configuration warnings when children are modified.
    child_order_changed.connect(update_configuration_warnings)

    for child in get_children():
        if child is State:
            _states[child.name.to_lower()] = child
            child.transitioned.connect(_on_state_transitioned)
            child._set_running(false)

    if initial_state == null:
        push_warning("StateMachine has no initial state.")
        return

    initial_state._set_running(true)
    initial_state.enter()


func _get_configuration_warnings() -> PackedStringArray:
    var warnings = PackedStringArray()

    if get_child_count() == 0:
        warnings.append("State machine has no child states.")

    if not initial_state is State:
        warnings.append("Initial state is not assigned, so this state machine will not run.")

    return warnings


## Transition the state machine to the new state named [param new_state_name].
func transition(new_state_name: String) -> void:
    var old_state = _current_state as State
    var new_state = _states[new_state_name.to_lower()] as State
    if new_state == null:
        push_error("Unknown state: %s" % new_state_name)
        return
    _current_state = new_state

    old_state.exit()
    old_state._set_running(false)

    new_state._set_running(true)
    new_state.enter()

    state_changed.emit(old_state, new_state)


func _on_state_transitioned(new_state_name: String) -> void:
    transition(new_state_name)
