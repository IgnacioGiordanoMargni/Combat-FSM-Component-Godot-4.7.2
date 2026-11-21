class_name Fighter extends CharacterBody3D

signal state_changed(previous_state: StringName, current_state: StringName)
signal health_changed(current: int, maximum: int)
signal stun_changed(current: float, maximum: float)
signal combo_changed(attack_name: String, buffered_name: String)
signal hit_confirmed(target: Fighter, damage: int)
signal hit_received(damage: int, from: Fighter)
signal attack_blocked(from: Fighter)
signal died(fighter: Fighter)

@export var is_player_controlled: bool = true
@export_range(0.5, 12.0, 0.1) var move_speed: float = 4.5
@export_range(1.0, 60.0, 0.5) var acceleration: float = 18.0
@export_range(1.0, 30.0, 0.5) var rotation_speed: float = 12.0
@export_range(0.0, 60.0, 0.5) var gravity: float = 18.0

@export_range(1, 9999, 1) var max_health: int = 100
@export_range(0.1, 10.0, 0.01) var max_stun: float = 1.0

@onready var fsm: CombatFSM = $FSM
@onready var health: HealthComponent = $HealthComponent
@onready var stun: StunComponent = $StunComponent
@onready var hitbox: HitboxComponent = $Hitbox
@onready var hurtbox: HurtboxComponent = $Hurtbox
@onready var visuals: FighterVisuals = $Visuals

var look_target: Fighter
var is_blocking: bool = false
var is_dead: bool = false
var current_attack_name: String = "READY"
var buffered_attack: String = ""

func _ready() -> void:
	health.configure(max_health)
	stun.configure(max_stun)

	health.health_changed.connect(_on_health_changed)
	stun.stun_changed.connect(_on_stun_changed)
	hitbox.hit_registered.connect(_on_hit_registered)
	fsm.state_changed.connect(_on_fsm_state_changed)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	_face_target(delta)
	move_and_slide()

func get_move_input() -> Vector2:
	if not is_player_controlled:
		return Vector2.ZERO
	return Input.get_vector(&"move_left", &"move_right", &"move_back", &"move_forward")

func has_move_input() -> bool:
	return get_move_input().length_squared() > 0.01

func is_light_pressed() -> bool:
	return is_player_controlled and Input.is_action_just_pressed(&"light_attack")

func is_heavy_pressed() -> bool:
	return is_player_controlled and Input.is_action_just_pressed(&"heavy_attack")

func is_block_held() -> bool:
	return is_player_controlled and Input.is_action_pressed(&"block")

func apply_movement(input: Vector2, delta: float, speed_multiplier: float = 1.0) -> void:
	var direction := Vector3(input.x, 0.0, -input.y).normalized()
	var target_velocity := direction * move_speed * speed_multiplier
	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)

func stop_movement(delta: float, friction: float = 12.0) -> void:
	var damping := exp(-friction * delta)
	velocity.x *= damping
	velocity.z *= damping

func halt_horizontal_movement() -> void:
	velocity.x = 0.0
	velocity.z = 0.0

func start_attack(data: AttackData) -> void:
	hitbox.configure(data.damage, data.stun, data.knockback)

	var forward := -transform.basis.z.normalized()
	velocity.x += forward.x * data.lunge_speed
	velocity.z += forward.z * data.lunge_speed

	set_combo_display(data.display_name, "")

func receive_hit(
	damage: int,
	stun_amount: float,
	knockback: float,
	from: Fighter
) -> int:
	if is_dead:
		return 0

	var final_damage := damage
	var final_stun := stun_amount
	var final_knockback := knockback

	if is_blocking:
		final_damage = maxi(1, int(round(float(damage) * 0.2)))
		final_stun *= 0.2
		final_knockback *= 0.25
		attack_blocked.emit(from)

	var applied := health.apply_damage(final_damage)
	if applied <= 0:
		return 0

	hit_received.emit(applied, from)

	var away := _get_knockback_direction(from)
	velocity.x = away.x * final_knockback
	velocity.z = away.z * final_knockback

	if health.current <= 0:
		fsm.change_state(&"Death")
	elif is_blocking:
		# Blocking absorbs the hit; no hurt/stun state is entered.
		pass
	elif stun.add_stun(final_stun):
		fsm.change_state(&"Stunned")
	else:
		fsm.change_state(&"Hurt")

	return applied

func set_combo_display(attack_name: String, buffered_name: String) -> void:
	current_attack_name = attack_name
	buffered_attack = buffered_name
	combo_changed.emit(attack_name, buffered_name)

func die() -> void:
	if is_dead:
		return

	is_dead = true
	velocity = Vector3.ZERO
	hitbox.set_active(false)
	hurtbox.monitoring = false
	hurtbox.monitorable = false
	visuals.slump()
	set_combo_display("DOWN", "")
	died.emit(self)

func respawn() -> void:
	health.reset()
	stun.clear()

	is_dead = false
	is_blocking = false
	velocity = Vector3.ZERO
	hitbox.set_active(false)
	hurtbox.monitoring = true
	hurtbox.monitorable = true
	visuals.reset()

	fsm.change_state(&"Idle")

func get_state_name() -> StringName:
	return fsm.current_state_name()

func _face_target(delta: float) -> void:
	if look_target == null or look_target == self or is_dead:
		return

	var to_target := look_target.global_position - global_position
	to_target.y = 0.0
	if to_target.length_squared() < 0.0001:
		return

	var desired_yaw := atan2(-to_target.x, -to_target.z)
	var blend := 1.0 - exp(-rotation_speed * delta)
	rotation.y = lerp_angle(rotation.y, desired_yaw, blend)

func _get_knockback_direction(from: Fighter) -> Vector3:
	if from == null:
		return Vector3.RIGHT

	var away := global_position - from.global_position
	away.y = 0.0
	if away.length_squared() < 0.0001:
		away = -from.transform.basis.z
	away.y = 0.0
	return away.normalized()

func _on_health_changed(current: int, maximum: int) -> void:
	health_changed.emit(current, maximum)

func _on_stun_changed(current: float, maximum: float) -> void:
	stun_changed.emit(current, maximum)

func _on_hit_registered(target: Node, damage: int) -> void:
	var fighter_target := target as Fighter
	if fighter_target != null:
		hit_confirmed.emit(fighter_target, damage)

func _on_fsm_state_changed(previous_state: StringName, current_state: StringName) -> void:
	state_changed.emit(previous_state, current_state)
