extends "res://Scripts/GroundTrack_ctrl.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
var progress = 0
func _on_Button_pressed():
	print("Hello")
	var orbit = $"%Orbit_Container".get_children()[0]
	var data = Dictionary()
	print("Test")
	for i in range(0,3600):
		progress = i
		orbit._on_aoa_in_value_changed(float(i)/10.0)
		var observation = calc_observations(orbit.period)
		data[float(i)/10.0] = observation
	var json_out = JSON.print(data,"\t")
	var file = File.new()
	file.open("user://data_orbit.json", File.WRITE)
	file.store_string(json_out)
	file.close()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
