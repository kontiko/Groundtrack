extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var passes = []
var positions = []
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
			draw_line(last_point*2,points[i]*2,col,2)
			last_point = points[i]
	for position_sat in positions:
		draw_circle(position_sat["position"]*2,5,position_sat["color"])
	for i in range(10):
		draw_arc(Vector2(0,0),i*20,0,2*PI,360,Color.red)
	for i in range(8):
		draw_line(Vector2(sin(i/4.0*PI),cos(i/4.0*PI))*180,
				  Vector2(-sin(i/4.0*PI),-cos(i/4.0*PI))*180,Color.red)
