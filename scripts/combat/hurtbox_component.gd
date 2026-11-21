class_name HurtboxComponent extends Area3D

@export var owner_fighter_path: NodePath = NodePath("..")

func get_owner_fighter() -> Fighter:
	return get_node_or_null(owner_fighter_path) as Fighter
