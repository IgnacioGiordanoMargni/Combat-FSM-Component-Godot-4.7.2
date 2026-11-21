class_name CombatState extends Node

signal transition_requested(target_state: StringName, data: Dictionary)

@export var state_name: StringName = &""

var fsm: CombatFSM
var fighter: Fighter

func setup(owner_fsm: CombatFSM, owner_fighter: Fighter) -> void:
	fsm = owner_fsm
	fighter = owner_fighter

func enter(_data: Dictionary = {}) -> void:
	pass

func exit() -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func request_transition(target_state: StringName, data: Dictionary = {}) -> void:
	transition_requested.emit(target_state, data)
