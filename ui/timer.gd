extends Node2D

var max_time = 60.0
var max_width = 487.5

@onready var line = $line

var colors = {
	30: "#66ff6aa5",
	20: "#ffe46ea5",
	10: "#f54d36a5"
}

func set_bar(time):
	var length = time / max_time * max_width
	line.points[0].x = -length 
	line.points[1].x = length
	
	if time <= 10:
		line.default_color = colors[10]
	elif time <= 20:
		line.default_color = colors[20]
	else:
		line.default_color = colors[30]
