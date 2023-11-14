extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var orbits = Dictionary()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _draw():
	print("test")
	#draw_line(Vector2(0,0),Vector2(1000,1000),Color.blue,20)
	for data in orbits:
		var color = orbits[data][0]
		var point_set = orbits[data][1]
		for i in range(0,len(point_set)-1,2):
			var p1 = point_set[i]+Vector2(0,300)
			var p2 = point_set[i+1]+Vector2(0,300)
			if abs(p1.x-p2.x)>512:
				#switch p1 and p2 if p1 the bigger point
				if p1.x>500:
					var p = p1
					p1 = p2
					p2 = p
				draw_line(p2,p1+Vector2(1024,0),color,1)
				draw_line(p2-Vector2(1024,0),p1,color,1)
			else:
					if p1.distance_to(p2)>0.1:
						draw_line(p1,p2,color,3)
					else:
						draw_circle(p1,1,color)
						draw_circle(p2,1,color)
