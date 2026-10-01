extends Sprite2D

# Geschwindigkeit in Pixel pro Sekunde
@export var speed: float = 400.0

func _ready() -> void:
	print("Player initialisiert am BRG Kepler!")

func _process(delta: float) -> void:
	var direction: Vector2 = Vector2.ZERO

	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	if Input.is_action_pressed("move_up"):
		direction.y -= 1

	if direction.length() > 0:
		direction = direction.normalized()

	position += direction * speed * delta
