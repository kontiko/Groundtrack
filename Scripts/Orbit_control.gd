extends VBoxContainer

signal changed(name)
signal delete(name)
export var periapsis = 100.0 
export var apoapsis = 100.0 
export (float) var semi_major 
export (float) var semi_minor 
export (float) var e 
var points = PoolVector3Array()
var mesh
var Vertices
var point_count = 7200
var reference_radius = 6371
var color = Color.green
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

func update_Mesh():
	delta_area = [0]
	var vertices = PoolVector3Array()
	var point_list = PoolVector3Array()
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
	time = (delta_area[pos]/complete_area)*time
	# Initialize the ArrayMesh.
	Vertices = vertices
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = vertices
	# Create the Mesh.
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	var mat = SpatialMaterial.new()
	mat.albedo_color = color
	for surface in arr_mesh.get_surface_count():
		arr_mesh.surface_set_material(surface,mat)
	mesh = arr_mesh

func calc_vec(angle: float):
	angle = fposmod(angle+PI,2*PI)
	var vec = Vector3(semi_major*sin(angle)/1000.0,0,semi_minor*cos(angle)/1000.0)
	vec = vec-Vector3((semi_major-periapsis-reference_radius)/1000.0,0,0)
	vec = vec.rotated(Vector3(0,1,0),aop/180.0*PI)
	vec = vec.rotated(Vector3(0,0,-1),incl/180.0*PI)
	vec = vec.rotated(Vector3(0,1,0),aoa/180.0*PI)
	return vec
# Called when the node enters the scene tree for the first time.
func _ready():
	$Control/LineEdit.text = name
	set_apo(apoapsis)
	changed()


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
	changed()


func _on_peri_in_value_changed(value):
	if value == (periapsis):
		return
	set_peri(value)
	changed()

func _on_major_in_value_changed(value):
	if value == (semi_major):
		return
	set_major(value)
	changed()

func _on_minor_in_value_changed(value):
	if value == semi_minor:
		return
	set_minor(value)
	changed()

func _on_Ecc_in_value_changed(value):
	if value == e:
		return
	set_e(value)
	changed()

func _on_ColorPickerButton_color_changed(color_in):
	color = color_in
	changed()

func _on_aop_in_value_changed(value):
	aop = value
	changed()

func _on_aoa_in_value_changed(value):
	aoa = value
	changed()
	changed()

func _on_Incl_in_value_changed(value):
	incl = value
	changed()

func _on_TextureButton_toggled(button_pressed):
	$Control/TextureButton.flip_v = button_pressed
	$Configs.visible = button_pressed

func _on_Button_pressed():
	emit_signal("delete",name)
	self.queue_free()

func _on_pos_in_value_changed(value):
	pos = int(value*point_count/360)
	time = delta_area[pos]/complete_area*period
	emit_signal("changed",name)

###############################################################################
#Update  Orbit parameters after one changed
###############################################################################

func changed():
	$Configs/apo_in.value = apoapsis
	$Configs/peri_in.value = periapsis
	$Configs/major_in.value = semi_major
	$Configs/minor_in.value = semi_minor
	$Configs/Ecc_in.value = e
	$Control/ColorPickerButton.color = color
	period = PlanetInfo.calc_Period(semi_major)
	update_Mesh()
	emit_signal("changed",name)


#Function run by Main to update position in real time
func update_postion(unix):
	time = unix
	var changed = false
	while last_orbit + period < unix:
		changed = true
		last_orbit += period
	while last_orbit - period > unix:
		changed = true
		last_orbit -= period
		#orbit_steps += period/PlanetInfo.rotation_period*2*PI
	if changed:
		emit_signal("changed",name)
	pos = searchpos(complete_area*float(time-last_orbit)/period)
	$Configs/pos_in.get_line_edit().text = str(pos*360.0/point_count)

func orbit_step():
	var dt = fposmod(last_orbit-PlanetInfo.solstice_unix_offset,PlanetInfo.period)
	var angle = 2*PI*dt/PlanetInfo.period
	var time_dict = Time.get_time_dict_from_unix_time(int(last_orbit))
	var earth_rot = (float(time_dict.hour)/24.0
					+float(time_dict.minute)/1440.0
					+float(time_dict.second)/86400)*2*PI
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
	var points_out = []
	var points_in = points
	for j in range(2):
		for i in range(len(points)):
			var ind_1 = (i )%point_count
			var o_1 = (i )/point_count
			var ind_2 = (i + 1 )%point_count
			var o_2 = (i + 1 )/point_count
			var p1 = to_2d(points[ind_1])
			var p2 = to_2d(points[ind_2])
			p1.x = p1.x + PlanetInfo.base_angle - (delta_area[ind_1]/complete_area+j+o_1)*period/PlanetInfo.rotation_period*2*PI - orbit_step()
			p2.x = p2.x + PlanetInfo.base_angle - (delta_area[ind_2]/complete_area+j+o_2)*period/PlanetInfo.rotation_period*2*PI - orbit_step()
			p2.x = fposmod(p2.x,2*PI)
			p1.x = fposmod(p1.x,2*PI)
			p1 = p1 * Vector2(1024.0/(2*PI),512.0/(PI))
			p2 = p2 * Vector2(1024.0/(2*PI),512.0/(PI))
			points_out.append(p1)
			points_out.append(p2)
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
	pos_2d.x += ((pos)/point_count)*period/PlanetInfo.rotation_period*2*PI
	pos_2d.x = fposmod(pos_2d.x,2*PI)
	pos_2d = pos_2d * Vector2(1024.0/(2*PI),512.0/(PI))
	return pos_2d


