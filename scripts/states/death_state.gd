class_name DeathState extends CombatState

func enter(_data: Dictionary = {}) -> void:
	fighter.die()
