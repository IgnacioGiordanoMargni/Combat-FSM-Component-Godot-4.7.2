class_name RunState extends CombatState

@export_range(0.1, 2.0, 0.01) var speed_multiplier: float = 1.0

func enter(_data: Dictionary = {}) -> void:
	fighter.set_combo_display("MOVE", "")

func physics_update(delta: float) -> void:
	if fighter.is_dead:
		return

	if fighter.is_light_pressed():
		request_transition(&"Light1")
		return
	if fighter.is_heavy_pressed():
		request_transition(&"Heavy1")
		return
	if fighter.is_block_held():
		request_transition(&"Block")
		return

	var input := fighter.get_move_input()
	if input.length_squared() <= 0.01:
		request_transition(&"Idle")
		return

	fighter.apply_movement(input, delta, speed_multiplier)
