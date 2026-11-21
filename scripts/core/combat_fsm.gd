class_name CombatFSM extends Node

signal state_changed(previous_state: StringName, current_state: StringName)

@export var initial_state: StringName = &"Idle"
@export var fighter_path: NodePath = NodePath("..")

var states: Dictionary = {}
var current_state: CombatState
var fighter: Fighter

func _ready() -> void:
	fighter = get_node_or_null(fighter_path) as Fighter

	for child in get_children():
		var state := child as CombatState
		if state == null:
			continue
		states[state.state_name] = state
		state.setup(self, fighter)
		state.transition_requested.connect(_on_transition_requested)

	# Defer so the owning Fighter's @onready references are initialized first.
	call_deferred("change_state", initial_state)

func _physics_process(delta: float) -> void:
	if current_state != null:
		current_state.physics_update(delta)

func change_state(next_state: StringName, data: Dictionary = {}) -> void:
	if not states.has(next_state):
		push_error("CombatFSM: state '%s' is not registered." % next_state)
		return

	var next := states[next_state] as CombatState
	if current_state == next:
		return

	var previous_name: StringName = current_state.state_name if current_state != null else &"None"

	if current_state != null:
		current_state.exit()

	current_state = next
	current_state.enter(data)
	state_changed.emit(previous_name, next_state)

func current_state_name() -> StringName:
	return current_state.state_name if current_state != null else &"None"

func _on_transition_requested(target_state: StringName, data: Dictionary) -> void:
	change_state(target_state, data)
