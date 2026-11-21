class_name CombatHUD extends Node

var _player: Fighter
var _dummy: Fighter

var _player_health: ProgressBar
var _dummy_health: ProgressBar
var _player_stun: ProgressBar
var _dummy_stun: ProgressBar
var _player_state: Label
var _dummy_state: Label
var _player_combo: Label
var _dummy_combo: Label
var _message: Label

var _message_timer: float = 0.0

func bind(player: Fighter, dummy: Fighter) -> void:
	_player = player
	_dummy = dummy

	_build_ui()

	_player.health_changed.connect(_on_player_health_changed)
	_dummy.health_changed.connect(_on_dummy_health_changed)
	_player.stun_changed.connect(_on_player_stun_changed)
	_dummy.stun_changed.connect(_on_dummy_stun_changed)
	_player.state_changed.connect(_on_player_state_changed)
	_dummy.state_changed.connect(_on_dummy_state_changed)
	_player.combo_changed.connect(_on_player_combo_changed)
	_dummy.combo_changed.connect(_on_dummy_combo_changed)

	_set_bar(_player_health, _player.health.current, _player.health.maximum)
	_set_bar(_dummy_health, _dummy.health.current, _dummy.health.maximum)
	_set_bar(_player_stun, _player.stun.current, _player.stun.maximum)
	_set_bar(_dummy_stun, _dummy.stun.current, _dummy.stun.maximum)
	_player_state.text = "STATE: %s" % _player.get_state_name()
	_dummy_state.text = "STATE: %s" % _dummy.get_state_name()

func flash_message(text: String) -> void:
	if _message == null:
		return
	_message.text = text
	_message_timer = 1.6

func _process(delta: float) -> void:
	if _message_timer <= 0.0 or _message == null:
		return
	_message_timer -= delta
	if _message_timer <= 0.0:
		_message.text = ""

func _build_ui() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	_create_status_panel(root, "PLAYER", Color(0.3, 0.65, 1.0), true)
	_create_status_panel(root, "TRAINING DUMMY", Color(1.0, 0.55, 0.3), false)

	var controls := Label.new()
	controls.position = Vector2(0.0, 668.0)
	controls.size = Vector2(1280.0, 36.0)
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.add_theme_font_size_override("font_size", 18)
	controls.add_theme_color_override("font_color", Color(0.85, 0.88, 0.95))
	controls.text = "WASD  MOVE     J  LIGHT     K  HEAVY     L  BLOCK     R  RESET"
	controls.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(controls)

	_message = Label.new()
	_message.position = Vector2(280.0, 318.0)
	_message.size = Vector2(720.0, 84.0)
	_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_message.add_theme_font_size_override("font_size", 30)
	_message.add_theme_color_override("font_color", Color(1.0, 0.95, 0.6))
	_message.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_message)

func _create_status_panel(root: Control, title: String, accent: Color, is_player: bool) -> void:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(330.0, 168.0)
	panel.position = Vector2(16.0, 16.0) if is_player else Vector2(934.0, 16.0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.06, 0.09, 0.88)
	style.border_color = accent
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	panel.add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 5)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(column)

	var title_label := Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.add_theme_color_override("font_color", accent)
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(title_label)

	var health_bar := ProgressBar.new()
	health_bar.max_value = 100.0
	health_bar.value = 100.0
	health_bar.show_percentage = true
	health_bar.custom_minimum_size = Vector2(0.0, 24.0)
	health_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(health_bar)

	var stun_bar := ProgressBar.new()
	stun_bar.max_value = 1.0
	stun_bar.value = 0.0
	stun_bar.show_percentage = false
	stun_bar.custom_minimum_size = Vector2(0.0, 12.0)
	stun_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(stun_bar)

	var state_label := Label.new()
	state_label.text = "STATE: --"
	state_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(state_label)

	var combo_label := Label.new()
	combo_label.text = "COMBO: --"
	combo_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(combo_label)

	root.add_child(panel)

	if is_player:
		_player_health = health_bar
		_player_stun = stun_bar
		_player_state = state_label
		_player_combo = combo_label
	else:
		_dummy_health = health_bar
		_dummy_stun = stun_bar
		_dummy_state = state_label
		_dummy_combo = combo_label

func _set_bar(bar: ProgressBar, current: float, maximum: float) -> void:
	if bar == null:
		return
	bar.max_value = maxf(0.001, maximum)
	bar.value = clampf(current, 0.0, maximum)

func _on_player_health_changed(current: int, maximum: int) -> void:
	_set_bar(_player_health, float(current), float(maximum))

func _on_dummy_health_changed(current: int, maximum: int) -> void:
	_set_bar(_dummy_health, float(current), float(maximum))

func _on_player_stun_changed(current: float, maximum: float) -> void:
	_set_bar(_player_stun, current, maximum)

func _on_dummy_stun_changed(current: float, maximum: float) -> void:
	_set_bar(_dummy_stun, current, maximum)

func _on_player_state_changed(_previous: StringName, current: StringName) -> void:
	_player_state.text = "STATE: %s" % current

func _on_dummy_state_changed(_previous: StringName, current: StringName) -> void:
	_dummy_state.text = "STATE: %s" % current

func _on_player_combo_changed(attack_name: String, buffered_name: String) -> void:
	_player_combo.text = _combo_text(attack_name, buffered_name)

func _on_dummy_combo_changed(attack_name: String, buffered_name: String) -> void:
	_dummy_combo.text = _combo_text(attack_name, buffered_name)

func _combo_text(attack_name: String, buffered_name: String) -> String:
	if buffered_name.is_empty():
		return "COMBO: %s" % attack_name
	return "COMBO: %s  ->  %s" % [attack_name, buffered_name]
