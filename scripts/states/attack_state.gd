class_name AttackState extends CombatState

@export var data: AttackData

var _elapsed: float = 0.0
var _hitbox_active: bool = false
var _buffered_attack: String = ""

func enter(_data: Dictionary = {}) -> void:
	if data == null:
		push_error("AttackState '%s' has no AttackData assigned." % state_name)
		return

	_elapsed = 0.0
	_hitbox_active = false
	_buffered_attack = ""

	fighter.hitbox.set_active(false)
	fighter.start_attack(data)
	fighter.visuals.play_attack_feedback(data)
	fighter.set_combo_display(data.display_name, "")

func exit() -> void:
	fighter.hitbox.set_active(false)
	fighter.set_combo_display(fighter.current_attack_name, "")

func physics_update(delta: float) -> void:
	if data == null or fighter.is_dead:
		return

	_elapsed += delta
	fighter.stop_movement(delta, 2.5)

	var should_be_active := _elapsed >= data.hitbox_active_start and _elapsed <= data.hitbox_active_end
	if should_be_active != _hitbox_active:
		_hitbox_active = should_be_active
		fighter.hitbox.set_active(should_be_active)

	_read_combo_buffer()

	if _elapsed >= data.duration:
		fighter.hitbox.set_active(false)
		if not _buffered_attack.is_empty():
			request_transition(StringName(_buffered_attack))
		elif fighter.has_move_input():
			request_transition(&"Run")
		else:
			request_transition(&"Idle")

func _read_combo_buffer() -> void:
	if _elapsed < data.combo_window_start or _elapsed > data.combo_window_end:
		return
	if not _buffered_attack.is_empty():
		return

	if fighter.is_light_pressed() and data.next_light != &"":
		_buffered_attack = String(data.next_light)
	elif fighter.is_heavy_pressed() and data.next_heavy != &"":
		_buffered_attack = String(data.next_heavy)
	else:
		return

	fighter.set_combo_display(data.display_name, _buffered_attack)
