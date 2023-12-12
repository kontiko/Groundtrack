extends VBoxContainer

var lat = 0.0
var lng = 0.0
#maximum angle to zenith at which an overflight gets registered
var observation_angle = 85
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
			orbit_pos = estimate_J2_effect(orbit_pos,orbit,int(sim_time-start_time)/orbit.period)
			#calculate rotation from earth
			var over_ground = calculate_projection(orbit_pos,sim_time)
			var zenith_angle = over_ground.angle_to(Vector3(0,0,1))*180.0/PI
			#if the angle is bigger than 90 degrees the satellite isn't visible anymore so skip further calculations
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
					current_overflight["points"] = []
				current_overflight["points"].append({"unix":sim_time,"pos":over_ground})
			pos += 1
			sim_time = start_time + orbit.period*(pos/orbit.point_count
								  + orbit.delta_area[pos%orbit.point_count]/orbit.complete_area)
		if current_overflight != null:
					current_overflight["end"] = sim_time
					overflights.append(current_overflight)
					current_overflight = null
	$overflight_table.set_table(overflights)
func calculate_projection(point:Vector3,time:float)->Vector3:
	var dt:float = fposmod(time-PlanetInfo.solstice_unix_offset,PlanetInfo.period)
	var sun_angle:float = 2*PI*dt/PlanetInfo.period
	var earth_rot:float = fposmod(time-43200.0,86400)/86400.0*2*PI
	var rot:float = earth_rot + sun_angle + lng
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
	$"%Groundtrack".queue_redraw()

func estimate_J2_effect(point,orbit,orbit_count):
	var node_precession = orbit.calc_LAN_precession()/180.0*PI*orbit_count
	var apsidal_precession = orbit.calc_Apsides_precession()/180.0*PI*orbit_count
	var new_LAN = orbit.aoa/180.0*PI + node_precession
	var apsidal_rotation_vector = Vector3(0,1,0)
	apsidal_rotation_vector = apsidal_rotation_vector.rotated(Vector3(0,0,1),orbit.incl/180.0*PI)
	apsidal_rotation_vector = apsidal_rotation_vector.rotated(Vector3(0,1,0),new_LAN)
	point = point.rotated(Vector3(0,1,0),node_precession)
	return point.rotated(apsidal_rotation_vector,apsidal_precession)
	

func update_overflight():
	#31.74
	var passes = []
	var current_pass = null
	for orbit in $"%Orbit_Container".get_children():
		for j in range(2):
			for pos in range(0,orbit.point_count,ceil(orbit.point_count/360)):
				var time = orbit.last_orbit + orbit.period*(j + orbit.delta_area[pos]/orbit.complete_area)
				var orbit_pos = orbit.points[pos]#estimate_J2_effect(orbit.points[pos],orbit,j)
				var over_ground = calculate_projection(orbit_pos,time)
				#check if zenith angle is smaller than 90 Degrees without calculating it first
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
						
	if current_pass != null:
		passes.append(current_pass)
		current_pass = null
	$"%Groundtrack".passes = passes
	$"%Groundtrack".queue_redraw()
func _on_Button_pressed():
	calc_observations(604800.0)


func _on_Lng_in_value_changed(value):
	lng = value/180.0*PI
	update_overflight()
	calculate_current_orbits()


func _on_Lat_in_value_changed(value):
	lat = value/180.0*PI
	update_overflight()
	calculate_current_orbits()
