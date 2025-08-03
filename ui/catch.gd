extends Node2D

var fish_sprites = {
	"red": preload("res://ui/catch/red.png"),
	"green": preload("res://ui/catch/green.png"),
	"blue": preload("res://ui/catch/blue.png"),
	"yellow": preload("res://ui/catch/yellow.png")
}

@onready var label = $RichTextLabel

var fish_sprite_scene = preload("res://ui/catch/fish_sprite.tscn")

var words = {
	"solo": "ONE FISH!",
	"pair": "A PAIR!",
	"diff2": "TWO FISH!!", 
	"diff3": "THREE FISH!!!",
	"2n1": "A PAIR (and one)!",
	"triple": "TRIPLE FISH!",
	"diff4": "FOUR FISH!!!!",
	"pair2": "TWO PAIRS!!",
	"2n1n1": "A PAIR (and two)!!",
	"3n1": "TRIPLE FISH (and one)!",
	"quadriple": "QUADRIPLE FISH!!!!",
	"2n2n1": "TWO PAIRS (and one)!!",
	"4n1": "QUADRIPLE FISH (and one)!!!",
	"quintuple": "QUINTUPLE FISH!?!?!?!",
	"3n2": "TRIPLE FISH (and a pair)!!",
	"3n1n1": "TRIPLE FISH (and two more)!",
	"other": "MANY MANY FISH!!!!!!!!"
}

func catch(type, fishes):
	self.visible = true 
	
	$one.visible = false 
	$two.visible = false 
	$three.visible = false 
	$more.visible = false
	
	label.visible = true
	label.text = "[wave amp=50.0 freq=5.0 connected=1]%s[/wave]" % words[type]
	
	if len(fishes) == 1:
		
		$one/fish_sprite.set_sprite(fish_sprites[fishes[0]])
		$one/fish_sprite.animate()
		$one.visible = true
		
		await get_tree().create_timer(2).timeout 
		$one/fish_sprite.end_animation()
	

	elif len(fishes) == 2:
		
		$two/fish_sprite.set_sprite(fish_sprites[fishes[0]])
		$two/fish_sprite.animate()
		$two/fish_sprite2.set_sprite(fish_sprites[fishes[1]])
		$two/fish_sprite2.animate(0.2)
		$two.visible = true 
		
		await get_tree().create_timer(2).timeout 
		$two/fish_sprite.end_animation()
		$two/fish_sprite2.end_animation()
		#$two/Sprite2D2.texture = fish_sprites[fishes[0]]
		#$two/Sprite2D3.texture = fish_sprites[fishes[1]]
	elif len(fishes) == 3:
		
		
		$three/fish_sprite.set_sprite(fish_sprites[fishes[0]])
		$three/fish_sprite.animate()
		$three/fish_sprite2.set_sprite(fish_sprites[fishes[1]])
		$three/fish_sprite2.animate(0.2)
		$three/fish_sprite3.set_sprite(fish_sprites[fishes[2]])
		$three/fish_sprite3.animate(0.4)
		$three.visible = true 
		
		
		await get_tree().create_timer(2).timeout 
		$three/fish_sprite.end_animation()
		$three/fish_sprite2.end_animation()
		$three/fish_sprite3.end_animation()
				
	else:
		var children = $more.get_children()
		for child in children:
			child.free()

		$more.visible = true
		
		var existing = []
		var sprite_scenes = []
		var delay = 0
		for fish in fishes:
			var new_sprite = fish_sprite_scene.instantiate()
			
		
			new_sprite.global_position = _get_valid_position(existing)
			existing.append(new_sprite.global_position)
			$more.add_child(new_sprite)
			sprite_scenes.append(new_sprite)
			new_sprite.set_sprite(fish_sprites[fish])
			new_sprite.animate(delay)
			delay += 0.2
		
		await get_tree().create_timer(2).timeout 
		
		for item in sprite_scenes:
			if item:
				item.end_animation()
			
	label.visible = false


var box_start = Vector2(300, 300)
var box_end = Vector2(750, 500)
var min_distance = 50
func _get_valid_position(existing_positions: Array) -> Vector2:
	var attempts = 0
	while attempts < 100:
		var pos = Vector2(
			randf_range(box_start.x, box_end.x),
			randf_range(box_start.y, box_end.y)
		)

		var valid = true
		for existing in existing_positions:
			if pos.distance_to(existing) < min_distance:
				valid = false
				break
		if valid:
			return pos
		attempts += 1

	return Vector2(
			randf_range(box_start.x, box_end.x),
			randf_range(box_start.y, box_end.y)
		)   
		
