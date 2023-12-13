extends MeshInstance3D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var points = []
var preview_pos = 0
var point_size = 0.05
# Called when the node enters the scene tree for the first time.
func _ready():
	set_preview(preview_pos)
	

func set_preview(pos):
	$Position.position = points[pos]
	
func _process(_delta):
	var camera = get_parent().find_child("Camera3D",true,true)
	var distance = ($Position.global_transform.origin - camera.global_transform.origin).length()
	$Position.scale = Vector3(distance*point_size,distance*point_size,distance*point_size)
