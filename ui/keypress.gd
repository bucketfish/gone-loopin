extends Control

@export var key_display = "" 
@export var key_to_press = ""

func _ready():
	$key.text = key_display 

func _input(event):
	if Input.is_action_just_pressed(key_to_press):
		self.modulate = "#65c769"
	elif Input.is_action_just_released(key_to_press):
		self.modulate = "#ffffff"
