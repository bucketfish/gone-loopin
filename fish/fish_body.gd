extends Node3D

var start = 0
var end = 0
var length = 0

@onready var body = $body

func _ready():
	$body.mesh.top_radius = start
	$body.mesh.bottom_radius = end 
	$body.mesh.height = length


func pulse():
	$body3.visible = true 
	$body4.visible = true
	$anim.play("pulse")
	
func end_pulse():
	$body3.visible = false 
	$body4.visible = false
	$anim.stop()
