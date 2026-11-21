class_name BlockState extends CombatState

func enter(_data: Dictionary = {}) -> void:
	fighter.is_blocking = true
	fighter.visuals.set_blocking(true)
	fighter.set_combo_display("BLOCK", "")

func exit() -> void:
	fighter.is_blocking = false
	fighter.visuals.set_blocking(false)

func physics_update(delta: float) -> void:
	if fighter.is_dead:
		return

	if fighter.is_light_pressed():
		request_transition(&"Light1")
		return
	if fighter.is_heavy_pressed():
		request_transition(&"Heavy1")
		return

	fighter.stop_movement(delta, 16.0)

	if not fighter.is_block_held():
		request_transition(&"Idle")
