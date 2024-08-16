@icon("res://scenes/components/state_machine/state.svg")
class_name State
extends Node
## A state to be used as part of a [StateMachine].
##
## Extend this script and override some or all of [method enter], [method exit],
## [method Node._process], [method Node._physics_process] and
## [method Node._input].[br]
## [method Node._process], [method Node._physics_process] and
## [method Node._input] will be disabled unless the state is running.[br][br]

## Emitted when this state transitions to another state.
## If the state machine doesn't recognize the new state it remains on the
## current state.
## State names are taken from their names in the scene tree.
signal transitioned(new_state: String)


## Call to transition the state machine to the state with name
## [param new_state].
## If the state machine doesn't recognize the new state it remains on the
## current state.
## State names are taken from their names in the scene tree.
func transition_to(new_state: String) -> void:
    transitioned.emit(new_state)


func _set_running(running: bool) -> void:
    set_process(running)
    set_physics_process(running)
    set_process_input(running)


## Called when this state is entered.
func enter() -> void:
    pass


## Called when this state is exited.
func exit() -> void:
    pass
