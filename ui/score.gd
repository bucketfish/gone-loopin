extends RichTextLabel

var score = 0

var tween: Tween = null

var game_pos = Vector2(84.0, 46.0)
var end_pos = Vector2(84.0, 200)

func end_game():
	text = "[wave amp=50.0 freq=5.0 connected=1][center]final score: %s[/center][/wave]" % str(score)
	
	
func backto_game():
	text = "0"
	
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
