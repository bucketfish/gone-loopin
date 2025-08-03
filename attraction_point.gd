extends Area3D


@export var collection: NodePath
@onready var main = get_node("/root/main")

func get_near_fishes():
	var fishes = [] 
	for area in get_overlapping_areas():
		if area.is_in_group("fish"):
			fishes.append(area.get_parent().get_parent())
			
	return fishes
		#
#func _on_area_entered(area):
	#if area.is_in_group("fish"):
		#var fish = area.get_parent().get_parent()
		#fish.debug_label.text = "caught!"
		#
		#fish.override_moveto(get_node(collection).global_position)
		#await get_tree().create_timer(0.8).timeout
		#main.caught_fish(fish)
