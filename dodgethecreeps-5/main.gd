extends Node

@export var mob_scene: PackedScene

const MAX_LIVES: int = 3
const SAVE_PATH: String = "user://highscore.cfg"
const MOB_WAIT_START: float = 0.5
const MOB_WAIT_MIN: float = 0.22

var score: int = 0
var highscore: int = 0
var lives: int = MAX_LIVES
var playing: bool = false
var new_record: bool = false

func _ready() -> void:
	load_highscore()
	$HUD.update_score(0)
	$HUD.update_highscore(highscore)
	$HUD.update_lives(MAX_LIVES)
	# Im Menue fliegen schon Creeps im Hintergrund herum
	$MobTimer.start()
	$HUD.show_menu("Dodge the Creeps",
		"Weiche den Creeps aus!\nSteuerung: WASD oder Pfeiltasten\nDu hast %d Leben." % MAX_LIVES)

func new_game() -> void:
	score = 0
	lives = MAX_LIVES
	new_record = false
	playing = true
	get_tree().call_group("mobs", "queue_free")
	$MobTimer.stop()
	$MobTimer.wait_time = MOB_WAIT_START
	$HUD.update_score(score)
	$HUD.update_lives(lives)
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$ScoreTimer.start()

func game_over() -> void:
	playing = false
	$StartTimer.stop()
	$ScoreTimer.stop()
	$Player.die()
	save_highscore()
	shake(22.0, 0.5)
	if $MobTimer.is_stopped():
		$MobTimer.start()
	await get_tree().create_timer(0.8).timeout
	var info: String = "Score: %d\nHighscore: %d" % [score, highscore]
	if new_record:
		info += "\nNeuer Highscore!"
	$HUD.show_menu("Game Over", info, "Nochmal")

func shake(strength: float = 12.0, duration: float = 0.3) -> void:
	var tw: Tween = create_tween()
	var steps: int = 6
	for i in steps:
		var falloff: float = 1.0 - float(i) / float(steps)
		var offset := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * strength * falloff
		tw.tween_property($Camera2D, "offset", offset, duration / float(steps + 1))
	tw.tween_property($Camera2D, "offset", Vector2.ZERO, duration / float(steps + 1))

func _on_player_hit(body: Node) -> void:
	if is_instance_valid(body) and body.has_method("explode"):
		body.explode()
	lives -= 1
	$HUD.update_lives(lives)
	shake(10.0, 0.3)
	if lives <= 0:
		game_over()

func _on_score_timer_timeout() -> void:
	score += 1
	$HUD.update_score(score)
	# Mit steigendem Score kommen die Creeps etwas oefter
	$MobTimer.wait_time = maxf(MOB_WAIT_MIN, MOB_WAIT_START - score * 0.012)
	if score > highscore:
		highscore = score
		new_record = true
		$HUD.update_highscore(highscore)

func _on_start_timer_timeout() -> void:
	$MobTimer.start()

func _on_mob_timer_timeout() -> void:
	var mob: RigidBody2D = mob_scene.instantiate()
	mob.add_to_group("mobs")

	var spawn: PathFollow2D = $MobPath/MobSpawnLocation
	spawn.progress_ratio = randf()
	mob.position = spawn.position

	var direction: float = spawn.rotation + PI / 2
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	var velocity := Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	add_child(mob)

func load_highscore() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		highscore = int(cfg.get_value("game", "highscore", 0))

func save_highscore() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("game", "highscore", highscore)
	cfg.save(SAVE_PATH)
