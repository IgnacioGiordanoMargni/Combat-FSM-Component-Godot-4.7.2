class_name StunComponent extends Node

signal stun_changed(current: float, maximum: float)
signal threshold_reached()

@export_range(0.1, 10.0, 0.01) var maximum: float = 1.0
@export_range(0.0, 10.0, 0.01) var decay_per_second: float = 0.65

var current: float = 0.0
var _threshold_emitted: bool = false

func _ready() -> void:
	configure(maximum)

func configure(new_maximum: float) -> void:
	maximum = maxf(0.1, new_maximum)
	current = 0.0
	_threshold_emitted = false
	stun_changed.emit(current, maximum)

func _physics_process(delta: float) -> void:
	if current <= 0.0:
		return
	current = maxf(0.0, current - decay_per_second * delta)
	if current <= 0.0:
		_threshold_emitted = false
	stun_changed.emit(current, maximum)

func add_stun(amount: float) -> bool:
	if amount <= 0.0:
		return false

	current = clampf(current + amount, 0.0, maximum)
	stun_changed.emit(current, maximum)

	if is_full() and not _threshold_emitted:
		_threshold_emitted = true
		threshold_reached.emit()
		return true

	return false

func is_full() -> bool:
	return current >= maximum - 0.0001

func clear() -> void:
	current = 0.0
	_threshold_emitted = false
	stun_changed.emit(current, maximum)
