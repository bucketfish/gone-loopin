extends Node2D

func set_sprite(texture):
	self.visible = false
	$Sprite2D.scale = Vector2(0.1, 0.1)
	$Sprite2D.texture = texture
	

func animate(delay = 0.0):
	if delay:
		await get_tree().create_timer(delay).timeout 
	
	$AnimationPlayer.play("show")
	self.visible = true
	await get_tree().create_timer(0.15).timeout
	get_parent().get_node("../pop").play()
	
func end_animation():
	$AnimationPlayer.play("hide")
