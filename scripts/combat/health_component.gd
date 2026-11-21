class_name HealthComponent extends Node

signal health_changed(current: int, maximum: int)
signal depleted()

@export_range(1, 9999, 1) var maximum: int = 100

var current: int = 100

func _ready() -> void:
	configure(maximum)

func configure(new_maximum: int) -> void:
	maximum = maxi(1, new_maximum)
	current = maximum
	health_changed.emit(current, maximum)

func apply_damage(amount: int) -> int:
	if amount <= 0 or current <= 0:
		return 0

	var before := current
	current = maxi(0, current - amount)
	var applied := before - current

	if applied > 0:
		health_changed.emit(current, maximum)
	if before > 0 and current == 0:
		depleted.emit()

	return applied

func reset() -> void:
	current = maximum
	health_changed.emit(current, maximum)
