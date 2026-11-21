extends Node3D

@onready var player: Fighter = $Player
@onready var dummy: Fighter = $Dummy
@onready var camera: Camera3D = $Camera3D
@onready var sun: DirectionalLight3D = $DirectionalLight3D
@onready var hud: CombatHUD = $UI/CombatHUD

func _ready() -> void:
	InputActions.ensure_actions()

	player.look_target = dummy
	dummy.look_target = player

	camera.look_at(Vector3(0.0, 1.0, 0.0))
	sun.rotation_degrees = Vector3(-45.0, -35.0, 0.0)

	hud.bind(player, dummy)

	player.hit_confirmed.connect(_on_player_hit_confirmed)
	dummy.hit_confirmed.connect(_on_dummy_hit_confirmed)
	player.died.connect(_on_player_died)
	dummy.died.connect(_on_dummy_died)

	hud.flash_message("PLAYER vs TRAINING DUMMY")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"restart"):
		_restart()

func _restart() -> void:
	player.respawn()
	dummy.respawn()
	hud.flash_message("RESET")

func _on_player_hit_confirmed(target: Fighter, damage: int) -> void:
	if target == dummy:
		hud.flash_message("PLAYER  >  DUMMY   -%d" % damage)

func _on_dummy_hit_confirmed(target: Fighter, damage: int) -> void:
	if target == player:
		hud.flash_message("DUMMY  >  PLAYER   -%d" % damage)

func _on_player_died(_fighter: Fighter) -> void:
	hud.flash_message("PLAYER DOWN  -  PRESS R TO RESET")

func _on_dummy_died(_fighter: Fighter) -> void:
	hud.flash_message("DUMMY DOWN  -  PRESS R TO RESET")
