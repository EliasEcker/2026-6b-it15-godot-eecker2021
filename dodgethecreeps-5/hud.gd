extends CanvasLayer

signal start_game

func _ready() -> void:
	%StartButton.pressed.connect(_on_start_button_pressed)
	%StartButton.resized.connect(func() -> void: %StartButton.pivot_offset = %StartButton.size / 2.0)
	# Der Start-Button "atmet" leicht
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(%StartButton, "scale", Vector2(1.06, 1.06), 0.6).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(%StartButton, "scale", Vector2.ONE, 0.6).set_trans(Tween.TRANS_SINE)

func show_menu(title: String, info: String, button_text: String = "Start") -> void:
	%TitleLabel.text = title
	%InfoLabel.text = info
	%StartButton.text = button_text
	%Menu.modulate.a = 0.0
	%Menu.show()
	create_tween().tween_property(%Menu, "modulate:a", 1.0, 0.4)
	%StartButton.grab_focus()

func update_score(value: int) -> void:
	%ScoreLabel.text = "Score: %d" % value
	%ScoreLabel.pivot_offset = Vector2(0.0, %ScoreLabel.size.y / 2.0)
	%ScoreLabel.scale = Vector2(1.25, 1.25)
	create_tween().tween_property(%ScoreLabel, "scale", Vector2.ONE, 0.25)

func update_highscore(value: int) -> void:
	%HighscoreLabel.text = "Highscore: %d" % value

func update_lives(value: int) -> void:
	var hearts: Array[Node] = %Hearts.get_children()
	for i in hearts.size():
		var h: TextureRect = hearts[i]
		var target: Color = Color.WHITE if i < value else Color(1, 1, 1, 0.18)
		if h.modulate != target:
			h.pivot_offset = h.size / 2.0
			h.scale = Vector2(1.5, 1.5)
			create_tween().tween_property(h, "scale", Vector2.ONE, 0.25)
		h.modulate = target

func _on_start_button_pressed() -> void:
	%Menu.hide()
	start_game.emit()
