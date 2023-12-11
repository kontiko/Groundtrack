extends VBoxContainer

signal changed(name)
signal delete(name)
@export var periapsis = 100.0 
@export var apoapsis = 100.0 
@export  var semi_major :float
@export  var semi_minor:float
@export  var e:float
var points = PackedVector3Array()
var mesh
var Vertices
var point_count = 7200
var reference_radius = 6371
var color = Color.GREEN
var aop = 0.0
var incl = 0.0
var aoa = 0.0
var period = 0
var time = 0.0
var last_orbit = 0.0
var pos = 0
var pos_offset = 0
var delta_area = []
var complete_area = 0.0
var orbit_steps = 0.0
var orbit_start_time = 0.0
func update_Mesh():
	delta_area = [0]
	var vertices = PackedVector3Array()
	var point_list = PackedVector3Array()
	var last_point = calc_vec(0)
	complete_area = 0.0
	point_list.push_back(last_point)
	for i in range(1,point_count):
		var point = calc_vec(float(i)/point_count*2*PI)
		vertices.push_back(last_point)
		vertices.push_back(point)
		point_list.push_back(point)
		var triangle = last_point.cross(point).length()/2.0
		complete_area+=triangle
		delta_area.append(complete_area)
		last_point = point
	points = point_list
	time = (delta_area[pos]/complete_area)*period+ last_orbit
	# Initialize the ArrayMesh.
	Vertices = vertices
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = vertices
	# Create the Mesh.
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	for surface in arr_mesh.get_surface_count():
		arr_mesh.surface_set_material(surface,mat)
	mesh = arr_mesh

func calc_vec(angle: float):
	#angle = fposmod(angle+PI,2*PI)
	var vec = Vector3(semi_minor*sin(angle)/1000.0,0,semi_major*cos(angle)/1000.0)
	vec = vec-Vector3(0,0,(semi_major-periapsis-PlanetInfo.radius)/1000.0)
	vec = vec.rotated(Vector3(0,1,0),aop/180.0*PI)
	vec = vec.rotated(Vector3(0,0,1),incl/180.0*PI)
	vec = vec.rotated(Vector3(0,1,0),aoa/180.0*PI)
	return vec
# Called when the node enters the scene tree for the first time.
func _ready():
	$Control/LineEdit.text = name
	set_apo(apoapsis)
	changed_in()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



################################################################################
#Sync basic orbit config
################################################################################
func set_peri(per):
	if per < apoapsis:
		periapsis = per
	else:
		periapsis = apoapsis
		apoapsis = per
	semi_major = (apoapsis+periapsis)/2+reference_radius
	e = 1-(periapsis+reference_radius)/semi_major
	semi_minor = semi_major*sqrt(1-pow(e,2))

func set_apo(apo):
	if apo > periapsis:
		apoapsis = apo
	else:
		apoapsis = periapsis
		periapsis = apo
	semi_major = (apoapsis+periapsis)/2+reference_radius
	e = 1-(periapsis+reference_radius)/semi_major
	semi_minor = semi_major*sqrt(1-pow(e,2))

func set_e(ecc):
	e = ecc
	semi_minor = sqrt(1- pow(e,2))*semi_major
	periapsis = semi_major - e*semi_major - reference_radius
	apoapsis = semi_major + e*semi_major - reference_radius

func set_major(major):
	if major > semi_minor:
		semi_major = major
	else:
		semi_major = semi_minor
		semi_minor = major
	e = sqrt(1-pow(semi_minor,2)/pow(semi_major,2))
	periapsis = semi_major - e*semi_major -reference_radius
	apoapsis = semi_major + e*semi_major -reference_radius

func set_minor(minor):
	
	if minor < semi_major:
		semi_minor = minor
	else:
		semi_minor = semi_major
		semi_major = minor
	e = sqrt(1-pow(semi_minor,2)/pow(semi_major,2))
	periapsis = semi_major - e*semi_major -reference_radius
	apoapsis = semi_major + e*semi_major -reference_radius


###############################################################################
#Button Pressed actions
###############################################################################
func _on_apo_in_value_changed(value):
	if value == (apoapsis):
		return
	set_apo(value)
	changed_in()


func _on_peri_in_value_changed(value):
	if value == (periapsis):
		return
	set_peri(value)
	changed_in()

func _on_major_in_value_changed(value):
	if value == (semi_major):
		return
	set_major(value)
	changed_in()

func _on_minor_in_value_changed(value):
	if value == semi_minor:
		return
	set_minor(value)
	changed_in()

func _on_Ecc_in_value_changed(value):
	if value == e:
		return
	set_e(value)
	changed_in()

func _on_ColorPickerButton_color_changed(color_in):
	color = color_in
	changed_in()

func _on_aop_in_value_changed(value):
	aop = value
	changed_in()

func _on_aoa_in_value_changed(value):
	aoa = value
	changed_in()

func _on_Incl_in_value_changed(value):
	incl = value
	changed_in()

func _on_TextureButton_toggled(button_pressed):
	$Control/TextureButton.flip_v = button_pressed
	$Configs.visible = button_pressed

func _on_Button_pressed():
	emit_signal("delete",name)
	self.queue_free()

func _on_pos_in_value_changed(value):
	pos = int(value*point_count/360)
	last_orbit = time - delta_area[pos]/complete_area*period
	emit_signal("changed",name)

###############################################################################
#Update  Orbit parameters after one changed
###############################################################################

func changed_in():
	$Configs/apo_in.set_value_code(apoapsis)
	$Configs/peri_in.set_value_code(periapsis)
	$Configs/major_in.set_value_code(semi_major)
	$Configs/minor_in.set_value_code(semi_minor)
	$Configs/aoa_in.set_value_code(aoa)
	$Configs/Ecc_in.set_value_code(e)
	$Control/ColorPickerButton.color = color
	period = PlanetInfo.calc_Period(semi_major)
	update_Mesh()
	emit_signal("changed",name)


#Function run by Main to update position in real time
func update_postion(unix):
	time = unix
	var changed = false
	#Change Last orbit var to timestep when the orbit started at periapsis
	while last_orbit + period < unix:
		changed = true
		last_orbit += period
		aoa += calc_LAN_precession()
		aop += calc_Apsides_precession()
	while unix < last_orbit :
		changed = true
		last_orbit -= period
		aoa -= calc_LAN_precession()
		aop -= calc_Apsides_precession()
	if changed:
		aoa= fposmod(aoa,360.0)
		changed_in()
		emit_signal("changed",name)
	pos = searchpos(complete_area*float(time-last_orbit)/period)
	$Configs/pos_in.set_value_code(pos*360.0/point_count)

#Calculate the distance the eath and sun rotated at the current specified unix time stamp
func orbit_step():
	var dt = fposmod(last_orbit-PlanetInfo.solstice_unix_offset,PlanetInfo.period)
	var angle = 2*PI*dt/PlanetInfo.period
	var time_dict = Time.get_time_dict_from_unix_time(int(last_orbit))
	var earth_rot = (float(time_dict.hour)/24.0
					+float(time_dict.minute)/1440.0
					+float(time_dict.second)/86400.0)*2*PI
	return earth_rot + angle + PI/2

#Find Current Positional index By Area gone with the helo of binary search
func searchpos(area):
	var start = 0
	var end = len(delta_area)
	var i = 0
	while end-start>1:
		i = i+1
		var probe_pos = (start+end)/2
		if delta_area[probe_pos]>area:
			end = probe_pos-1
		else:
			start = probe_pos
	return start

#Calculate ground path
func calc_groundpath():
	var steps = orbit_step()
	var points_out = []
	var points_in = points
	for j in range(2):
		var last_point = to_2d(points[0])
		last_point.x = last_point.x + PlanetInfo.base_angle - (j)*period/PlanetInfo.rotation_period*2*PI - steps
		last_point.x = fposmod(last_point.x,2*PI)
		last_point = last_point* Vector2(1024.0/(2*PI),512.0/(PI))
		for i in range(len(points)):
			var ind_2 = (i + 1)%point_count
			var o_2 = (i + 1)/point_count
			var p2 = to_2d(points[ind_2])
			p2.x = p2.x + PlanetInfo.base_angle - (delta_area[ind_2]/complete_area+j+o_2)*period/PlanetInfo.rotation_period*2*PI - steps
			p2.x = fposmod(p2.x,2*PI)
			p2 = p2 * Vector2(1024.0/(2*PI),512.0/(PI))
			points_out.append(last_point)
			points_out.append(p2)
			last_point = p2
	var low_res = []
	var point_steps = point_count/360
	for i in range(0,len(points_out),point_steps):
		low_res.append(points_out[i+0])
		low_res.append(points_out[i+point_steps-1])
	return low_res

#Calculate Lat,Lng, coordinates for Point by Normalizing the Vectors
func to_2d(point):
	var point_in  = point.normalized()
	var lng = fposmod(atan2(point_in.x,point_in.z),2*PI)
	var lat = -asin(point_in.y)
	return Vector2(lng,lat)

#Calculate Current Position of sattelite in Lat,Lng Coordinate Space
func current_pos_2d():
	var pos_2d = to_2d(points[pos])
	pos_2d.x += PlanetInfo.base_angle - (delta_area[pos]/complete_area)*period/PlanetInfo.rotation_period*2*PI - orbit_step()
	pos_2d.x = fposmod(pos_2d.x,2*PI)
	pos_2d = pos_2d * Vector2(1024.0/(2*PI),512.0/(PI))
	return pos_2d

func calc_LAN_precession():
	return -3*180*PlanetInfo.J_2*pow(PlanetInfo.radius_eq,2)/pow(pow(semi_minor,2)/semi_major,2)*cos(incl*PI/180)
	
func calc_Apsides_precession():
	return -3*90*PlanetInfo.J_2*pow(PlanetInfo.radius_eq,2)/(2*pow(pow(semi_minor,2)/semi_major,2))*(4-5*pow(sin(incl*PI/180),2))

func get_orbit_dict()->Dictionary:
	var dict = {
		"semi_minor":semi_minor,
		"semi_major":semi_major,
		"incl":incl,
		"aoa":aoa,
		"aop":aop,
		"pos":pos,
		"last_orbit":last_orbit,
		"time":time,
		"color":color,
		"name":$Control/LineEdit.text
	}
	return dict
func set_orbit_dict(dict:Dictionary):
	semi_major = dict["semi_major"]
	set_minor(dict["semi_minor"])
	incl = dict["incl"]
	aoa = dict["aoa"]
	aop = dict["aop"]
	pos = dict["pos"]
	last_orbit = dict["last_orbit"]
	time = dict["time"]
	color = dict["color"]
	$Control/LineEdit.text = dict["name"]
	changed_in()
