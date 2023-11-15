extends SpinBox


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func set_value_code(val):
	set_value_no_signal(val)
	get_line_edit().text = str(self.value)
