class_name AttackData extends Resource

@export var id: StringName = &"attack"
@export var display_name: String = "Attack"

@export_range(0.05, 2.0, 0.01) var duration: float = 0.45
@export_range(0, 100, 1) var damage: int = 10
@export_range(0.0, 2.0, 0.01) var stun: float = 0.25
@export_range(0.0, 20.0, 0.1) var knockback: float = 4.0

@export_range(0.0, 2.0, 0.01) var hitbox_active_start: float = 0.12
@export_range(0.0, 2.0, 0.01) var hitbox_active_end: float = 0.26

@export_range(0.0, 2.0, 0.01) var combo_window_start: float = 0.18
@export_range(0.0, 2.0, 0.01) var combo_window_end: float = 0.44

@export var next_light: StringName = &""
@export var next_heavy: StringName = &""

@export_range(0.0, 12.0, 0.1) var lunge_speed: float = 2.0
@export var pose_color: Color = Color(1.0, 0.82, 0.25, 1.0)
