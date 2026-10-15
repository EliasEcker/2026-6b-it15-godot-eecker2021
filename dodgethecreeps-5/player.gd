extends Area2D

signal hit(body: Node)

@export var speed: int = 400
@export var invulnerable_time: float = 1.5

var screen_size: Vector2
var alive: bool = false
var blink_tween: Tween

func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()

func _process(delta: float) -> void:
	if not alive:
		return

	var velocity: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	var moving: bool = velocity.length() > 0
	$Trail.emitting = moving
	if moving:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	# Animationsauswahl
	$AnimatedSprite2D.flip_v = false
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y < 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_h = false
	elif velocity.y > 0:
		$AnimatedSprite2D.animation = "down"
		$AnimatedSprite2D.flip_h = false

func _on_body_entered(body: Node2D) -> void:
	if not alive:
		return
	hit.emit(body)
	# Falls das Spiel durch diesen Treffer vorbei ist, nichts mehr tun
	if not alive:
		return
	$Burst.restart()
	$CollisionShape2D.set_deferred("disabled", true)
	_start_invulnerability()

func _start_invulnerability() -> void:
	if blink_tween:
		blink_tween.kill()
	blink_tween = create_tween().set_loops(6)
	blink_tween.tween_property($AnimatedSprite2D, "modulate:a", 0.2, invulnerable_time / 12.0)
	blink_tween.tween_property($AnimatedSprite2D, "modulate:a", 1.0, invulnerable_time / 12.0)
	await get_tree().create_timer(invulnerable_time).timeout
	if alive:
		$AnimatedSprite2D.modulate = Color.WHITE
		$CollisionShape2D.set_deferred("disabled", false)

func start(pos: Vector2) -> void:
	position = pos
	alive = true
	if blink_tween:
		blink_tween.kill()
	$AnimatedSprite2D.modulate = Color.WHITE
	$AnimatedSprite2D.show()
	show()
	$CollisionShape2D.set_deferred("disabled", false)

func die() -> void:
	alive = false
	if blink_tween:
		blink_tween.kill()
	$AnimatedSprite2D.modulate = Color.WHITE
	$AnimatedSprite2D.hide()
	$Trail.emitting = false
	$Burst.restart()
	$CollisionShape2D.set_deferred("disabled", true)
