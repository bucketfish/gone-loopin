extends MeshInstance3D

@export var start: Vector3 
@export var end: Vector3

var velocity = 0



func update_location():
	var direction = end - start
	var center = (start + end) / 2
	
	velocity = center - self.global_position
	self.global_position = center

	# Get the rotation that points the cylinder's +Y axis in the direction
	var up = direction.normalized()
	var right = up.cross(Vector3.FORWARD).normalized()
	var forward = right.cross(up).normalized()

	self.transform.basis = Basis(right, up, forward)

	# Scale cylinder to match the length (default height is 2 units)
	self.scale = Vector3(1, direction.length() / 0.5, 1)
