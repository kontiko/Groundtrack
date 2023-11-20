extends VBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var lat = 53.075833/180.0*PI
var lng = 8.807222/180.0*PI
#maximum angle to zenith at which an overflight gets registered
var observation_angle = 70
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func calc_observations(preview_window):
	var overflights = []
	var current_overflight = null
	for orbit in $"%Orbit_Container".get_children():
		var pos = orbit.pos 
		var start_time = orbit.last_orbit
		var sim_time = orbit.time
		var final_time = sim_time + preview_window
		while sim_time < final_time:
			var  orbit_pos: Vector3 = orbit.points[pos%orbit.point_count]
			var rotations = pos/orbit.point_count
			#calculate rotation from earth
			var over_ground = calculate_projection(orbit_pos,sim_time)
			var zenith_angle = over_ground.angle_to(Vector3(0,0,1))*180.0/PI
			#print(zenith_angle)
			#if the angle is 
			if zenith_angle>observation_angle:
				if current_overflight != null:
					current_overflight["end"] = sim_time
					overflights.append(current_overflight)
					current_overflight = null
			else:
				var altitude = 90.0 - zenith_angle
				if current_overflight != null:
					if altitude > current_overflight["altitude"]:
						current_overflight["altitude"]= altitude
				else:
					current_overflight = Dictionary()
					current_overflight["name"] = orbit.name
					current_overflight["start"] = sim_time
					current_overflight["altitude"] = altitude
			pos += 1
			sim_time = start_time + orbit.period*(pos/orbit.point_count
								  + orbit.delta_area[pos%orbit.point_count]/orbit.complete_area)
		if current_overflight != null:
					current_overflight["end"] = sim_time
					overflights.append(current_overflight)
					current_overflight = null
	print(overflights)
func calculate_projection(point,time):
	var dt = fposmod(time-PlanetInfo.solstice_unix_offset,PlanetInfo.period)
	var sun_angle = 2*PI*dt/PlanetInfo.period
	var time_dict = Time.get_time_dict_from_unix_time(int(time))
	var earth_rot = (float(time_dict.hour)/24.0
			+float(time_dict.minute)/1440.0
			+float(time_dict.second)/86400)*2*PI
	var rot = earth_rot + sun_angle + lng + PI
	#Transform the points so that the observation point lies at the origin and looks in the direction of the x axis
	return point.rotated(Vector3(0,1,0),-rot).rotated(Vector3(1,0,0),lat)- Vector3(0,0,PlanetInfo.radius/1000.0)

func calculate_current_orbits():
	var positions = []
	for orbit in $"%Orbit_Container".get_children():
		var pos_3d = orbit.points[orbit.pos]
		var over_ground = calculate_projection(pos_3d,orbit.time)
		var zenith_angle = over_ground.angle_to(Vector3(0,0,1))*180.0/PI
		if zenith_angle>90:
			continue
		var pos_2d = Vector2(over_ground.x,-over_ground.y).normalized()*zenith_angle
		var data = {"position":pos_2d,"color":orbit.color}
		positions.append(data)
	$"%Groundtrack".positions = positions
	$"%Groundtrack".update()
	

func update_overflight():
	var passes = []
	var current_pass = null
	for orbit in $"%Orbit_Container".get_children():
		for j in range(2):
			for pos in orbit.point_count:
				var time = orbit.last_orbit + orbit.period*(j + orbit.delta_area[pos]/orbit.complete_area)
				var over_ground = calculate_projection(orbit.points[pos],time)
				var zenith_angle = over_ground.angle_to(Vector3(0,0,1))*180.0/PI
				if zenith_angle<90:
					var direction = Vector2(over_ground.x,-over_ground.y).normalized()*zenith_angle
					if current_pass == null:
						current_pass = Dictionary()
						current_pass["color"] = orbit.color
						current_pass["points"] = []
					current_pass["points"].append(direction)
				else:
					if current_pass != null:
						passes.append(current_pass)
						current_pass = null
	$"%Groundtrack".passes = passes
	$"%Groundtrack".update()
func _on_Button_pressed():
	calc_observations(604800.0)


func _on_Lng_in_value_changed(value):
	var lng = value/180.0*PI


func _on_Lat_in_value_changed(value):
	var lat = value/180.0*PI
