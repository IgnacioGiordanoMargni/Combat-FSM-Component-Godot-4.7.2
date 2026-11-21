class_name StunnedState extends CombatState

@export_range(0.1, 3.0, 0.01) var duration: float = 0.9

var _elapsed: float = 0.0

func enter(_data: Dictionary = {}) -> void:
	_elapsed = 0.0
	fighter.visuals.play_stun_feedback()
	fighter.set_combo_display("STUNNED", "")

func physics_update(delta: float) -> void:
	_elapsed += delta
	fighter.stop_movement(delta, 10.0)

	if _elapsed >= duration:
		fighter.stun.clear()
		request_transition(&"Idle")
