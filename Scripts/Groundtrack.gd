extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var passes = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _draw():
	for overpass in passes:
		var col = overpass["color"]
		var points = overpass["points"]
		if len(points)<2:
			continue
		var last_point = points[0]
		for i in range(1,len(points)):
			draw_line(last_point,points[i],col,2)
			last_point = points[i]
