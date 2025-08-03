extends Node3D

@onready var left_hand = $left_hand
@onready var right_hand = $right_hand
@onready var rope = $rope

@onready var ui = $ui
@onready var catchzone = $attraction
@onready var center = $center

var timer = 60.0

var score = 0
var multiplier = 1.0

var fish_scene = preload("res://fish/fish.tscn")

@onready var fish_spawns = [$fish_spawn, $fish_spawn2]
@onready var gameover = $gameover

var game_phase = "opening"


@onready var ui_catch = $ui/catch
@onready var ui_timer = $ui/timer
@onready var ui_score = $ui/score


var catch_timer = 0.0
var catch_threshold = 0.7

var tutorial4_count = 0
var tutorial5_count = 0

func _ready():
	$ui/multiplier.modulate.a = 0.0
	$ui/score.modulate.a = 0.0
	$ui/timer.modulate.a = 0.0
	
	$ui/opening.visible = true 
	$ui/tutorial1.modulate.a = 0.0 
	$ui/tutorial2.modulate.a = 0.0
	$ui/tutorial3.modulate.a = 0.0
	$ui/tutorial4.modulate.a = 0.0
	$ui/tutorial5.modulate.a = 0.0
	$ui/tutorial6.modulate.a = 0.0
	
	$ui/tutorial1.visible = true 
	$ui/tutorial2.visible = true 
	$ui/tutorial3.visible = true 
	$ui/tutorial4.visible = true 
	$ui/tutorial5.visible = true
	$ui/tutorial6.visible = true
	pass

func end_game():
	$gameover.visible = true
	get_tree().paused = true
	

func start_game():
	for i in range(10):
		if get_tree().get_nodes_in_group("fish").size() < 10:
			spawn_fish()
			
	var tween = create_tween().set_parallel(true)
	tween.tween_property($ui/opening, "modulate:a", 0.0, 0.2)
	tween.tween_property($ui/tutorial6, "modulate:a", 0.0, 0.2)
	
	tween.tween_property($ui/multiplier, "modulate:a", 1.0, 0.2)
	tween.tween_property($ui/score, "modulate:a", 1.0, 0.2)
	tween.tween_property($ui/timer, "modulate:a", 1.0, 0.2)
	game_phase = "game"
	await tween.finished 
	tween.kill()


func start_tutorial1():
	var tween = create_tween().set_parallel(true)
	tween.tween_property($ui/opening, "modulate:a", 0.0, 0.2)
	tween.tween_property($ui/tutorial1, "modulate:a", 1.0, 0.2)
	game_phase = "tutorial1"
	await tween.finished
	tween.kill()

func start_tutorial2():
	var tween = create_tween().set_parallel(true)
	tween.tween_property($ui/tutorial1, "modulate:a", 0.0, 0.2)
	tween.tween_property($ui/tutorial2, "modulate:a", 1.0, 0.2)
	game_phase = "tutorial2"
	await tween.finished
	tween.kill()
	
	spawn_fish()
	
	
func start_tutorial3():
	var tween = create_tween().set_parallel(true)
	tween.tween_property($ui/tutorial2, "modulate:a", 0.0, 0.2)
	tween.tween_property($ui/tutorial3, "modulate:a", 1.0, 0.2)
	await tween.finished
	tween.kill()
	
	await get_tree().create_timer(0.5).timeout
	
	game_phase = "tutorial3"
	
	
func start_tutorial4():
	var tween = create_tween().set_parallel(true)
	tween.tween_property($ui/tutorial3, "modulate:a", 0.0, 0.2)
	tween.tween_property($ui/score, "modulate:a", 1.0, 0.2)
	
	score += 5
	ui_score.update_score(score)
	await tween.finished
	tween.kill()
	
	await get_tree().create_timer(1).timeout
	
	tween = create_tween()
	tween.tween_property($ui/tutorial4, "modulate:a", 1.0, 0.2)
	
	game_phase = "tutorial4"
	
	spawn_fish()
	spawn_fish()
	
	
func start_tutorial5():
	var tween = create_tween().set_parallel(true)
	tween.tween_property($ui/tutorial4, "modulate:a", 0.0, 0.2)
	tween.tween_property($ui/multiplier, "modulate:a", 1.0, 0.2)
	
	await tween.finished
	tween.kill()
	
	await get_tree().create_timer(1).timeout
	
	tween = create_tween()
	tween.tween_property($ui/tutorial5, "modulate:a", 1.0, 0.2)
	
	game_phase = "tutorial5"

func start_tutorial6():
	var tween = create_tween().set_parallel(true)
	tween.tween_property($ui/tutorial5, "modulate:a", 0.0, 0.2)
	tween.tween_property($ui/timer, "modulate:a", 1.0, 0.2)
	
	await tween.finished
	tween.kill()
	
	kill_all_fish()
	
	await get_tree().create_timer(1).timeout
	
	tween = create_tween()
	tween.tween_property($ui/tutorial6, "modulate:a", 1.0, 0.2)
	
	game_phase = "tutorial6"
	
func _process(delta):
	
	if game_phase in ["opening", "tutorial1", "tutorial2", "tutorial3", "tutorial4", "tutorial5", "tutorial6"]:
		rope_pulling()
	
	elif game_phase == "game":
		timer -= delta
		
		if timer < 0:
			end_game()
		
		ui_timer.set_bar(timer)
		

		
		catch_timer += delta
		
		multiplier = lerp(multiplier, 1.0, delta * 0.2)
		
		$ui/multiplier.text = str(int(multiplier)) + "x multiplier"

		rope_pulling()
		
	if game_phase in ["game", "tutorial4", "tutorial5"]:
		while get_tree().get_nodes_in_group("fish").size() < 10:
			spawn_fish()

func rope_pulling():
	

	var left_hand_dir = Input.get_axis("left_extend", "left_retract")
	if left_hand_dir < 0:
		rope.add_segment_left()
	elif left_hand_dir > 0:
		rope.remove_segment_left()

	var right_hand_dir = Input.get_axis("right_extend", "right_retract")
	if right_hand_dir < 0:
		rope.add_segment_right() 
	elif right_hand_dir > 0:
		rope.remove_segment_right()
		
	
func match_combo(freq_counts):
	match freq_counts:
		[1]: return "solo"
		
		[2]: return "pair"
		[1, 1]: return "diff2"
		
		
		[1, 1, 1]: return "diff3"
		[1, 2]: return "2n1"
		[3]: return "triple"
		
		[1, 1, 1, 1]: return "diff4"
		[2, 2]: return "pair2"
		[1, 1, 2]: return "2n1n1"
		[1, 3]: return "3n1"
		[4]: return "quadriple"
		
		[1, 2, 2]: return "2n2n1"
		[1, 4]: return "4n1"
		[2, 3]: return "3n2"
		[1, 1, 3]: return "3n1n1"
		[5]: return "quintuple"
		
		
		_: return "other"
		
		
var combos = { # score = 5x of multiplier
	"solo": 1,
	"pair": 3,
	"diff2": 2, 
	"diff3": 15,
	"2n1": 3,
	"triple": 20,
	"diff4": 40,
	"pair2": 25,
	"2n1n1": 10,
	"3n1": 15,
	"quadriple": 50,
	"2n2n1": 15,
	"4n1": 25,
	"quintuple": 100,
	"3n2": 20,
	"3n1n1": 15,
	"other": 10
}

func catch_fish():
	
	if game_phase == "opening":
		start_tutorial1()
	
	elif game_phase == "tutorial3":
		var fish_type = ""
		var caught_fishes = catchzone.get_near_fishes()
		if !caught_fishes.is_empty():
			for fish in caught_fishes:
				fish_type = fish.fish_type
				fish.queue_free()
			
			ui_catch.catch("solo", [fish_type])
				
			start_tutorial4()
			
	elif game_phase == "tutorial6":
		start_game()
		
	elif game_phase in ["game", "tutorial4", "tutorial5"]:
			
		var caught_fishes = catchzone.get_near_fishes()
		var combo = ""
		
		var types = {}
		var total = []
		
		if game_phase == "game":
			if catch_timer > catch_threshold && !caught_fishes.is_empty():
				catch_timer = 0
			else:
				return
		
		for fish in caught_fishes:
			if fish.fish_type in types:
				types[fish.fish_type] += 1
			else:
				types[fish.fish_type] = 1
			total.append(fish.fish_type)
			fish.queue_free()
			
		
		if caught_fishes:
			
			if game_phase == "tutorial4":
				tutorial4_count += 1
				
			elif game_phase == "tutorial5":
				tutorial5_count += 1
			
			
			var freq_counts = types.values()
			freq_counts.sort()
			combo = match_combo(freq_counts)
			
			
			while get_tree().get_nodes_in_group("fish").size() < 10:
				spawn_fish()
			#$ui/catching.text = combo
				
			score += (combos[combo] * 5) * multiplier
			
			if game_phase == "game" or game_phase == "tutorial5":
				multiplier *= combos[combo]
			
			ui_score.update_score(score)
			
			$ui/multiplier.text = "multiplier: " + str(multiplier) + "x"
			
			timer = clamp(timer + float(combos[combo]) / 4, 0, 60)


			ui_catch.catch(combo, total)
			
			
			await get_tree().create_timer(1.5).timeout 
			
			if game_phase == "tutorial4":
				if tutorial4_count >= 3:
					start_tutorial5()
			elif game_phase == "tutorial5":
				if tutorial5_count >= 2:
					start_tutorial6()

func many_segments():
	if game_phase == "opening":
		start_game()
	elif game_phase == "tutorial1":
		start_tutorial2()
		
func spawn_fish():
	
	var types = ["red", "green", "yellow", "blue"]
	
	var newfish = fish_scene.instantiate()
	newfish.fish_type = types.pick_random()
	var spawnpoint = fish_spawns.pick_random()
	newfish.scale = Vector3(0.5, 0.5, 0.5)
	add_child(newfish)
	newfish.global_position = spawnpoint.global_position


func _on_attraction_area_entered(area):
	if game_phase == "tutorial2":
		if area.is_in_group("fish"):
			start_tutorial3()

func kill_all_fish():
	get_tree().call_group("fish_whole", "queue_free")
