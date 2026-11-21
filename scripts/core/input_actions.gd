class_name InputActions extends RefCounted
## Runtime input-action registration.
##
## Keeping this in code makes the component safe to drop into a fresh project
## without editing Project Settings. A host project may still define the same
## actions in project.godot; existing actions are left untouched.

const ACTIONS := {
	&"move_left": KEY_A,
	&"move_right": KEY_D,
	&"move_forward": KEY_W,
	&"move_back": KEY_S,
	&"light_attack": KEY_J,
	&"heavy_attack": KEY_K,
	&"block": KEY_L,
	&"restart": KEY_R,
}

static func ensure_actions() -> void:
	for action_name in ACTIONS.keys():
		var action: StringName = action_name
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action, 0.5)

		var event := InputEventKey.new()
		event.physical_keycode = ACTIONS[action]
		InputMap.action_add_event(action, event)
