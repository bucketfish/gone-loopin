extends Label

var score = 0

var tween: Tween = null

func update_score(new_score):
	score = int(round(new_score))
	
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1).set_ease(Tween.EASE_IN)
	await tween.finished
	text = str(score)
	await get_tree().create_timer(0.05).timeout
	tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.05).set_ease(Tween.EASE_OUT)
