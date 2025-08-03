extends Node3D


@export var fish_type: String

@export var head: Node3D
var body_segments: Array[Node3D] = []



const FRICTION = 0.05

@onready var main = get_node("/root/main")
@onready var debug_label = $head/Label3D
@export var segment_spacing: float = 1.0 

@export var fish_shape : Array[float] = []

var fish_body_scene = preload("res://fish/fish_body.tscn")

var countdown = 0.0 
var count_to = 0.0

var rope_velocity = Vector3()
var velocity = Vector3()

var hit_border = false

var moveto = null

var textures = {
	"red": preload("res://fish/types/red.tres"),
	"blue": preload("res://fish/types/blue.tres"),
	"yellow": preload("res://fish/types/yellow.tres"),
	"green": preload("res://fish/types/green.tres")
}

func _ready():
	for i in range(len(fish_shape) - 1):
		var new_body = fish_body_scene.instantiate()
		new_body.start = fish_shape[i]
		new_body.end = fish_shape[i+1]
		new_body.length = segment_spacing 
		add_child(new_body)
		new_body.body.material_override = textures[fish_type]
		body_segments.append(new_body)
		

	var velocity = Vector3(randf_range(-0.02, 0.02), 0, randf_range(-0.02, 0.02))

	
	# FISH TYPE / COLOR.
	
	$head.material_override = textures[fish_type]



func _process(delta):
	
	if moveto:
		self.velocity = self.global_position.direction_to(moveto) * 0.2
		
	else:
		var touching_border_thistime = false
		if !self:
			return
		for body in $head/near_rope.get_overlapping_bodies():
			if body.is_in_group("segment_collision"):
				if main.rope.is_point_in_rope(body.global_position + body.get_parent().velocity * 1):
					rope_velocity = (main.rope.center - body.global_position).normalized() * 0.2
					if (main.rope.center - body.global_position).length() < 1:
						rope_velocity *= 3
					rope_velocity.y = 0
			
					
		countdown += delta
		if countdown >= count_to:
			velocity.x += randf_range(-0.05, 0.05)
			velocity.z += randf_range(-0.05, 0.05)
			count_to = randf_range(5, 15)
			countdown = 0
			
			velocity.x = clamp(velocity.x, -0.1, 0.1)
			velocity.z = clamp(velocity.z, -0.1, 0.1)
		
	# move fish head!!!!
	
	var new_pos = $head.global_position
	if (velocity + rope_velocity).length() > 0.001:
			
		if rope_velocity:
			new_pos += velocity * 0.1 + rope_velocity
		else:
			new_pos += velocity
		rope_velocity = rope_velocity.move_toward(Vector3.ZERO, FRICTION * delta)
		
		$head.look_at((new_pos), Vector3.UP)
		$head.global_position = new_pos
	
	# fish bits follow body
	var prev_pos = head.global_transform.origin

	for i in body_segments.size():
		var segment = body_segments[i]
		var to_prev = prev_pos - segment.global_transform.origin
		var dist = to_prev.length()

		if dist > 0.001:
			var direction = to_prev.normalized()

			# spacing logic: first segment tucks halfway in
			var spacing = segment_spacing * scale.x

			var target_pos = prev_pos - direction * spacing
			segment.global_transform.origin = target_pos

			# rotate to face previous segment
			segment.look_at(prev_pos, Vector3.UP)

		prev_pos = segment.global_transform.origin


func _on_near_rope_body_entered(body):
	if body.is_in_group("surrounding"):
		velocity = (main.center.global_position - head.global_position).normalized() * randf_range(0.01, 0.1)
		

func override_moveto(pos: Vector3):
	moveto = pos


func _on_near_rope_area_entered(area):
	if area.is_in_group("attraction"):
		pulse()
		
		for body in body_segments:
			body.pulse()
			
			
func _on_near_rope_area_exited(area):
	if area.is_in_group("attraction"):
		end_pulse()
		
		for body in body_segments:
			body.end_pulse()

func pulse():
	$head/head3.visible = true 
	$head/head4.visible = true
	$head/anim.play("pulse")
	
func end_pulse():
	$head/head3.visible = false 
	$head/head4.visible = false
	$head/anim.stop()
