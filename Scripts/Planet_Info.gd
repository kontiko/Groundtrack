extends Node

var radius = 6371
var Mass = 5.9722e24
const grav_const = 6.6743e-11
var base_angle = PI/2
var period = 31558149.7635
var solstice_unix_offset = 22869862.5345 - period/2.0
var rotation_period = 86164.1
var specific_grav = 3.986025446e5
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
	return 2*PI*sqrt(pow(semi_major,3)/(specific_grav))
