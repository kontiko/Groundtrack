extends HBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal time_changed(time)
var time = 0.0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
var days_in_month

func set_time(unix):
	time = unix
	update_display()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func update_display():
	var time_dict = Time.get_datetime_dict_from_unix_time(int(time))
	$Year.set_value_code(time_dict.year)
	$Month.set_value_code(time_dict.month)
	$Day.set_value_code(time_dict.day)
	$Hour.set_value_code(time_dict.hour)
	$Minute.set_value_code(time_dict.minute)
	$Second.set_value_code(time_dict.second)

func _on_Year_value_changed(value):
	var date_time = Time.get_datetime_dict_from_unix_time(int(time))
	date_time.year = value
	time = correct_day_of_month(date_time)
	emit_signal("time_changed",time)
	update_display()


func _on_Month_value_changed(value):
	var date_time = Time.get_datetime_dict_from_unix_time(int(time))
	print(int(value))
	date_time.month = value
	if value>12:
		date_time.year += 1
		date_time.month = 1
	if value == 0:
		date_time.year -= 1
		date_time.month = 12
	time = correct_day_of_month(date_time)
	emit_signal("time_changed",time)
	update_display()


func _on_Day_value_changed(value):
	var current_day = Time.get_datetime_dict_from_unix_time(int(time)).day
	time = time + (value-current_day)*86400
	emit_signal("time_changed",time)

func _on_Hour_value_changed(value):
	print("Hello")
	var current_hour = Time.get_datetime_dict_from_unix_time(int(time)).hour
	print(value-current_hour)
	time = time + (value-current_hour)*3600
	print(current_hour)
	emit_signal("time_changed",time)

func _on_Minute_value_changed(value):
	print("Test")
	var current_min = Time.get_datetime_dict_from_unix_time(int(time)).minute
	time = time + (value-current_min)*60
	emit_signal("time_changed",time)


func _on_Second_value_changed(value):
	var current_sec = Time.get_datetime_dict_from_unix_time(int(time)).second
	time = time + (value-current_sec)
	emit_signal("time_changed",time)

func correct_day_of_month(date_dict):
	var time = Time.get_unix_time_from_datetime_dict({"year":date_dict.year,
													 "month":date_dict.month,
													 "day":1,
													 "hour":date_dict.hour,
													 "minute":date_dict.minute,
													 "second":date_dict.second,})
	return time + 86400.0*(date_dict.day-1)


func _on_Minute_changed():
	pass # Replace with function body.
