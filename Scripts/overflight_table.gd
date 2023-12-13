extends GridContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_table([])


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_table(dict_arr):
	for child in get_children():
		child.queue_free()
	var start_label = Label.new()
	start_label.text = "Begins at"
	self.add_child(start_label)
	var end_label = Label.new()
	end_label.text = "Ends at"
	self.add_child(end_label)
	var alt = Label.new()
	alt.text = "Max Alt"
	self.add_child(alt)
	for row in dict_arr:
		add_row(row)
func add_row(dict):
	var start_label = Label.new()
	start_label.text = Time.get_datetime_string_from_unix_time(dict["start"])
	self.add_child(start_label)
	var end_label = Label.new()
	end_label.text = Time.get_datetime_string_from_unix_time(dict["end"])
	self.add_child(end_label)
	var alt = Label.new()
	alt.text = str(dict["altitude"])
	self.add_child(alt)

