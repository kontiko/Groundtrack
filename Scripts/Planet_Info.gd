extends Node

var radius = 6371
var Mass = 5.9722e24
const grav_const = 6.667e-11
var base_angle = PI/2
var period = 31558149.7635
var solstice_unix_offset = 22869862.5345
var rotation_period = 86164.0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func calc_Period(semi_major):
	return 2*PI*sqrt(pow(semi_major*1000,3)/(Mass*grav_const))

