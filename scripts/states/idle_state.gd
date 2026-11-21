class_name IdleState extends CombatState

func enter(_data: Dictionary = {}) -> void:
	fighter.visuals.play_idle_feedback()
	fighter.set_combo_display("READY", "")

func physics_update(delta: float) -> void:
	if fighter.is_dead:
		return

	# No residual horizontal velocity while idle: releasing a direction,
	# finishing a lunge, or recovering from hit stun stops the capsule here.
	fighter.halt_horizontal_movement()

	if fighter.is_light_pressed():
		request_transition(&"Light1")
		return
	if fighter.is_heavy_pressed():
		request_transition(&"Heavy1")
		return
	if fighter.is_block_held():
		request_transition(&"Block")
		return
	if fighter.has_move_input():
		request_transition(&"Run")
