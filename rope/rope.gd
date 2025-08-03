extends Node3D

#func _ready():
	#$segment.update_location()
	#pass
	#

@export var environment_collision: NodePath


@export_group("Appearance")
## Number of segments
@export var segmentNumber = 5
## Length of each segment
@export var segmentLength = 0.5

@export_group("Normal Physics")
## Number of times to check for positional accuracy of points of the scarf. Lower number = more bouncy, higher number = more accurate (but may take more processing).
@export var iterations = 5
### Downward gravity applied to the scarf
#@export var gravity = 15
## Amount of energy in graph. Higher number is more reactive to movement... kinda.
@export var clampPercent = 0.4
## Node to follow for movement. Set to empty if the scarf moves relative to its own position.
@export var left_hand: NodePath
@export var right_hand: NodePath

#@export_group("Wind Physics")
#@export var amplitude = 0.1
#@export var frequency = 4
### If length of regular vector is above this number, don't apply wind — it's moving hella fast already, lol. this feels so scam
#@export var wind_threshold = 5


var segment_scene = preload("res://rope/segment.tscn")

var wave_time = 0
var points_now = []
var points_old = []

var segments = []

var vel_old = []

var xdir = 0


var growth_timer := 0.0
var growth_duration := 0.3
var new_segment_data = null
var is_growing := false


var center = Vector3()


@onready var main = get_node("/root/main")

func _ready():
	#if !follow_node:
		#follow_node = self.get_path()
	
	load_rope()
	
	#for i in range(segmentNumber):
		#var light = VerletScarfLightClass.instantiate()
		#if i % lightRenderInterval == 0:
			#$LightGroups.add_child(light)
	

func _process(delta):
	#wave_time += delta
	draw_rope()
	simulate(delta) 
	
	calculate_center()
	

func calculate_center():
	var max_x = -300
	var max_z = -300
	var min_x = 300
	var min_z = 300
	for point in points_now:
		max_x = max(point.x, max_x)
		max_z = max(point.z, max_z)
		min_x = min(point.x, min_x)
		min_z = min(point.z, min_z)
	
	center = Vector3((max_x + min_x) / 2, 0, (max_z + min_z) / 2)
	
	

	
func draw_rope():
	
	for i in range(len(points_now) - 1):
		segments[i].start = points_now[i]
		segments[i].end = points_now[i+1]
		segments[i].update_location()
	#
	#var set_points = []
	#
	#for point in points_now:
		#set_points.append(point)
	
	
	
	#self.points = set_points
func load_rope():
	points_now.clear()
	points_old.clear()
	vel_old.clear()
	segments.clear()

	var left = get_node(left_hand).global_position
	var right = get_node(right_hand).global_position
	
	var center = (left + right) * 0.5
	var right_dir = (right - left).normalized()
	var up_dir = Vector3.UP  # assume arc should bend upward/outward in global Y — change if needed
	var normal = up_dir.cross(right_dir).normalized()

	var radius = (left - center).length()

	for i in range(segmentNumber):
		var t = float(i) / (segmentNumber - 1)  # 0 to 1
		var angle = lerp(PI * 0.5, -PI * 0.5, t)

		# rotate the normal vector around the "right_dir" axis to make the arc
		var rotated = normal.rotated(right_dir, angle) * radius
		var pos = center + rotated

		points_now.append(pos)
		points_old.append(pos)
		vel_old.append(Vector3())
		
		if i < segmentNumber - 1:
			var new_segment = segment_scene.instantiate()
			new_segment.start = pos
			new_segment.end = pos  # will be updated later
			segments.append(new_segment)
			add_child(new_segment)

		
	
	
	
func simulate(delta):
	# Calculate new position
	# get loop center
	var center = Vector3.ZERO
	for p in points_now:
		center += p
	center /= len(points_now)

	# simulate
	for i in range(len(points_now)):
		var vel = clampPercent * (points_now[i] - points_old[i])
		points_old[i] = points_now[i]

		var dir = (points_now[i] - center).normalized()
		vel += dir * 2 * delta
		vel += Vector3(0, 0, -1) * 4 * delta
		
		#if points_now[i].y > 1 and points_now[i].z > 0:
			#vel += Vector3(0, -1, 0) * 1 * delta 

		points_now[i] += vel
		vel_old[i] = vel

	# apply collision correction
	apply_collisions()

		
	# Apply constraints!!!!!
	for i in range(0, iterations):
		applyconstaints()
	

func applyconstaints():
	points_now[0] = get_node(left_hand).global_position
	points_now[len(points_now) - 1] = get_node(right_hand).global_position
	
	for i in range(0, len(points_now) - 1):
		var dist = (points_now[i] - points_now[i+1]).length()
		var error = abs(dist - segmentLength)
		var changedir = Vector2()
		
		# Correct segment length
		if dist > segmentLength:
			changedir = (points_now[i] - points_now[i + 1]).normalized()
		else:
			changedir = (points_now[i + 1] - points_now[i]).normalized()
			
		var changeamt = changedir * error
		
		# Apply slight changes so the error is corrected. yay :)
		if i != 0 and i + 1 != len(points_now) - 1:
			points_now[i] -= changeamt * 0.5
			points_now[i + 1] += changeamt * 0.5
		elif i == 0:
			points_now[i + 1] += changeamt
		elif i + 1 == len(points_now) - 1:
			points_now[i] -= changeamt

			
func add_segment_left():
	var dir = (points_now[0] - points_now[1]).normalized()
	var spacing = (points_now[0] - points_now[1]).length()
	var new_pos = points_now[0] + dir * spacing

	points_now.insert(0, new_pos)
	points_old.insert(0, new_pos)
	vel_old.insert(0, Vector3())

	var new_segment = segment_scene.instantiate()
	new_segment.start = new_pos
	new_segment.end = points_now[1]
	segments.insert(0, new_segment)
	add_child(new_segment)

func add_segment_right():
	var last = points_now.size() - 1
	var dir = (points_now[last] - points_now[last - 1]).normalized()
	var spacing = (points_now[last] - points_now[last - 1]).length()
	var new_pos = points_now[last] + dir * spacing

	points_now.append(new_pos)
	points_old.append(new_pos)
	vel_old.append(Vector3())

	var new_segment = segment_scene.instantiate()
	new_segment.start = points_now[last]
	new_segment.end = new_pos
	segments.append(new_segment)
	add_child(new_segment)
	
	if len(segments) > 80:
		main.many_segments()
	
	
	
func remove_segment_left():
	if points_now.size() <= 2:
		return  # prevent deleting too much

	points_now.remove_at(0)
	points_old.remove_at(0)
	vel_old.remove_at(0)

	var segment = segments[0]
	segments.remove_at(0)
	segment.queue_free()
	
	if len(segments) < 17:
		taut_rope()

func remove_segment_right():
	if points_now.size() <= 2:
		return  # prevent deleting too much

	points_now.remove_at(points_now.size() - 1)
	points_old.remove_at(points_old.size() - 1)
	vel_old.remove_at(vel_old.size() - 1)

	var segment = segments[segments.size() - 1]
	segments.remove_at(segments.size() - 1)
	segment.queue_free()

	if len(segments) < 15:
		taut_rope()
		
		
		
func apply_collisions():
	var space_state = get_world_3d().direct_space_state
	var shape = SphereShape3D.new()
	shape.radius = 0.1

	for i in range(points_now.size()):
		var transform = Transform3D(Basis(), points_now[i])
		var params = PhysicsShapeQueryParameters3D.new()
		params.shape = shape
		params.transform = transform
		params.collide_with_areas = false
		params.collide_with_bodies = true

		var results = space_state.intersect_shape(params)

		if results.size() > 0:
			var collision = results[0]
			if collision.has("normal"):
				var push = collision.normal * 0.1
				points_now[i] += push



func is_point_in_rope(point: Vector3):
	var point_2d = Vector2(point.x, point.z)
	
	var poly := PackedVector2Array()
	for p in points_now:
		poly.append(Vector2(p.x, p.z))
	
	return Geometry2D.is_point_in_polygon(point_2d, poly)


func taut_rope():
	main.catch_fish()
