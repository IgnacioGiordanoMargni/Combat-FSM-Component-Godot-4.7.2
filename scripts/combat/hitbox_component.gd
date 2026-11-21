class_name HitboxComponent extends Area3D

signal hit_registered(target: Node, damage: int)

@export var owner_fighter_path: NodePath = NodePath("..")
@export_range(0, 100, 1) var damage: int = 10
@export_range(0.0, 2.0, 0.01) var stun: float = 0.25
@export_range(0.0, 20.0, 0.1) var knockback: float = 4.0

var is_active: bool = false

var _hit_targets: Dictionary = {}

func _ready() -> void:
	monitoring = false
	monitorable = false
	area_entered.connect(_on_area_entered)

func configure(new_damage: int, new_stun: float, new_knockback: float) -> void:
	damage = new_damage
	stun = new_stun
	knockback = new_knockback

func set_active(value: bool) -> void:
	is_active = value
	monitoring = value
	if not value:
		_hit_targets.clear()

func get_owner_fighter() -> Fighter:
	return get_node_or_null(owner_fighter_path) as Fighter

func _on_area_entered(area: Area3D) -> void:
	if not is_active:
		return

	var hurtbox := area as HurtboxComponent
	if hurtbox == null:
		return

	var attacker := get_owner_fighter()
	var target := hurtbox.get_owner_fighter()
	if attacker == null or target == null or target == attacker:
		return

	var target_id := target.get_instance_id()
	if _hit_targets.has(target_id):
		return
	_hit_targets[target_id] = true

	var applied := target.receive_hit(damage, stun, knockback, attacker)
	hit_registered.emit(target, applied)
