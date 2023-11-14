tool
extends MeshInstance

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var point_count = 360
var points = []
var preview_pos = 0
var color = Color.white
# Called when the node enters the scene tree for the first time.
func _ready():
	set_preview(preview_pos)
	

func set_preview(pos):
	$Position.translation = points[pos]
	
