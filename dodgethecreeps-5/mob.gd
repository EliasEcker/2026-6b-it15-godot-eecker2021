extends RigidBody2D

const TINTS: Dictionary = {
	"fly": Color(0.75, 0.5, 1.0),
	"swim": Color(0.3, 0.85, 1.0),
	"walk": Color(1.0, 0.6, 0.3),
}

var exploded: bool = false

func _ready() -> void:
	var animation_names: PackedStringArray = $AnimatedSprite2D.sprite_frames.get_animation_names()
	$AnimatedSprite2D.animation = animation_names[randi() % animation_names.size()]
	# Nicht kopfueber fliegen, wenn der Creep nach links unterwegs ist
	$AnimatedSprite2D.flip_v = cos(rotation) < 0.0
	$AnimatedSprite2D.speed_scale = randf_range(0.8, 1.3)
	$AnimatedSprite2D.play()

func explode() -> void:
	if exploded:
		return
	exploded = true
	$CollisionShape2D.set_deferred("disabled", true)

	var parent: Node = get_parent()
	var tint: Color = TINTS.get(String($AnimatedSprite2D.animation), Color(1.0, 0.6, 0.2))
	var ring: Line2D = _make_ring(tint)

	parent.add_child.call_deferred(_make_fire())
	parent.add_child.call_deferred(_make_debris(tint))
	parent.add_child.call_deferred(ring)

	var tw: Tween = get_tree().create_tween().set_parallel(true)
	tw.tween_property(ring, "scale", Vector2(5.0, 5.0), 0.45).set_ease(Tween.EASE_OUT)
	tw.tween_property(ring, "modulate:a", 0.0, 0.45)
	tw.chain().tween_callback(ring.queue_free)

	queue_free()

func _make_fire() -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.position = global_position
	p.one_shot = true
	p.amount = 60
	p.lifetime = 0.7
	p.explosiveness = 1.0
	p.spread = 180.0
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = 120.0
	p.initial_velocity_max = 360.0
	p.damping_min = 80.0
	p.damping_max = 160.0
	p.scale_amount_min = 5.0
	p.scale_amount_max = 11.0
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.35, 1.0])
	g.colors = PackedColorArray([Color(1.0, 0.97, 0.5, 1.0), Color(1.0, 0.4, 0.05, 1.0), Color(0.15, 0.15, 0.15, 0.0)])
	p.color_ramp = g
	p.emitting = true
	p.finished.connect(p.queue_free)
	return p

func _make_debris(tint: Color) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.position = global_position
	p.one_shot = true
	p.amount = 22
	p.lifetime = 0.9
	p.explosiveness = 1.0
	p.spread = 180.0
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = 80.0
	p.initial_velocity_max = 260.0
	p.damping_min = 40.0
	p.damping_max = 90.0
	p.scale_amount_min = 6.0
	p.scale_amount_max = 12.0
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 1.0])
	g.colors = PackedColorArray([tint, Color(tint.r, tint.g, tint.b, 0.0)])
	p.color_ramp = g
	p.emitting = true
	p.finished.connect(p.queue_free)
	return p

func _make_ring(tint: Color) -> Line2D:
	var ring := Line2D.new()
	var pts := PackedVector2Array()
	for i in 33:
		var a: float = TAU * float(i) / 32.0
		pts.append(Vector2(cos(a), sin(a)) * 20.0)
	ring.points = pts
	ring.width = 6.0
	ring.default_color = tint.lerp(Color.WHITE, 0.5)
	ring.position = global_position
	return ring

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
