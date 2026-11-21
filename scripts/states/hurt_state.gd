class_name HurtState extends CombatState

@export_range(0.05, 1.0, 0.01) var duration: float = 0.3

var _elapsed: float = 0.0

func enter(_data: Dictionary = {}) -> void:
	_elapsed = 0.0
	fighter.visuals.play_hurt_feedback()
	fighter.set_combo_display("HURT", "")

func physics_update(delta: float) -> void:
	_elapsed += delta
	fighter.stop_movement(delta, 8.0)

	if _elapsed >= duration:
		request_transition(&"Idle")
