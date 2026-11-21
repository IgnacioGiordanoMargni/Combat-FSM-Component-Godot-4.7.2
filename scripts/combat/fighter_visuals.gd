class_name FighterVisuals extends Node3D

@export var body_path: NodePath = NodePath("Body")
@export var idle_color: Color = Color(0.22, 0.55, 1.0, 1.0)
@export var block_color: Color = Color(0.25, 0.85, 0.7, 1.0)

var _body: MeshInstance3D
var _material: StandardMaterial3D
var _base_color: Color
var _tween: Tween

func _ready() -> void:
	_body = get_node_or_null(body_path) as MeshInstance3D
	if _body == null:
		push_error("FighterVisuals: body node '%s' was not found." % body_path)
		return

	var source_material := _body.material_override as StandardMaterial3D
	if source_material == null:
		source_material = StandardMaterial3D.new()

	_material = source_material.duplicate() as StandardMaterial3D
	_body.material_override = _material

	_base_color = idle_color
	_material.albedo_color = _base_color
	_material.metallic = 0.1
	_material.roughness = 0.55

func play_idle_feedback() -> void:
	if _material == null:
		return
	_kill_tween()
	_tween = create_tween()
	_tween.tween_property(_body, "rotation:x", 0.0, 0.12)
	_tween.parallel().tween_property(_body, "rotation:z", 0.0, 0.12)
	_tween.parallel().tween_property(_body, "scale", Vector3.ONE, 0.12)
	_tween.parallel().tween_property(_material, "albedo_color", _base_color, 0.12)

func play_attack_feedback(data: AttackData) -> void:
	if _body == null or _material == null or data == null:
		return
	_kill_tween()
	_material.albedo_color = data.pose_color

	_tween = create_tween()
	_tween.tween_property(_body, "rotation:z", -0.38, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(_body, "scale", Vector3(1.12, 0.9, 1.12), 0.08)
	_tween.tween_property(_body, "rotation:z", 0.0, 0.18).set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(_body, "scale", Vector3.ONE, 0.18)
	_tween.tween_property(_material, "albedo_color", _base_color, 0.2)

func play_hurt_feedback() -> void:
	if _body == null or _material == null:
		return
	_kill_tween()
	_material.albedo_color = Color(1.0, 0.25, 0.25, 1.0)

	_tween = create_tween()
	_tween.tween_property(_body, "rotation:x", 0.28, 0.06)
	_tween.parallel().tween_property(_body, "scale", Vector3(0.92, 1.08, 0.92), 0.06)
	_tween.tween_property(_body, "rotation:x", 0.0, 0.18)
	_tween.tween_property(_body, "scale", Vector3.ONE, 0.18)
	_tween.tween_property(_material, "albedo_color", _base_color, 0.2)

func play_stun_feedback() -> void:
	if _body == null or _material == null:
		return
	_kill_tween()
	_material.albedo_color = Color(1.0, 0.85, 0.1, 1.0)

	_tween = create_tween()
	_tween.tween_property(_body, "rotation:y", 0.5, 0.1)
	_tween.parallel().tween_property(_body, "scale", Vector3(1.06, 0.94, 1.06), 0.1)
	_tween.tween_property(_body, "rotation:y", -0.5, 0.2)
	_tween.tween_property(_body, "scale", Vector3.ONE, 0.2)
	_tween.tween_property(_body, "rotation:y", 0.0, 0.2)
	_tween.tween_property(_material, "albedo_color", _base_color, 0.2)

func set_blocking(value: bool) -> void:
	if _material == null:
		return
	_kill_tween()
	_material.albedo_color = block_color if value else _base_color

	_tween = create_tween()
	_tween.tween_property(_body, "scale", Vector3(1.08, 0.94, 1.08) if value else Vector3.ONE, 0.1)

func slump() -> void:
	if _body == null or _material == null:
		return
	_kill_tween()
	_material.albedo_color = Color(0.35, 0.35, 0.4, 1.0)
	_body.rotation = Vector3(-1.15, 0.0, 0.12)
	_body.scale = Vector3(1.05, 0.85, 1.05)

func reset() -> void:
	if _body == null or _material == null:
		return
	_kill_tween()
	_body.rotation = Vector3.ZERO
	_body.scale = Vector3.ONE
	_material.albedo_color = _base_color

func _kill_tween() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null
