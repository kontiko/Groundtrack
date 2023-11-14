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
var point_count = 3600
var reference_radius = 6371
var color = Color.green
var aop = 0.0
var incl = 0.0
var aoa = 0.0
var period = 0


func update_Mesh():
	var vertices = PoolVector3Array()
	var point_list = PoolVector3Array()
	var last_point = calc_vec(0)
	point_list.push_back(last_point)
	for i in range(1,point_count):
		var point = calc_vec(float(i)/point_count*2*PI)
		vertices.push_back(last_point)
		vertices.push_back(point)
		point_list.push_back(point)
		last_point = point
	points = point_list
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


func _on_TextureButton_toggled(button_pressed):
	print(button_pressed)
	$Control/TextureButton.flip_v = button_pressed
	$Configs.visible = button_pressed


func _on_Button_pressed():
	emit_signal("delete",name)
	self.queue_free()


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
	

func changed():
	$Configs/apo_in.value = apoapsis
	$Configs/peri_in.value = periapsis
	$Configs/major_in.value = semi_major
	$Configs/minor_in.value = semi_minor
	$Configs/Ecc_in.value = e
	$Control/ColorPickerButton.color = color
	var period = PlanetInfo.calc_Period(semi_major)
	update_Mesh()
	emit_signal("changed",name)



func _on_ColorPickerButton_color_changed(color_in):
	color = color_in
	changed()


func _on_aop_in_value_changed(value):
	aop = value
	changed()


func _on_aoa_in_value_changed(value):
	aoa = value
	changed()


func _on_Incl_in_value_changed(value):
	incl = value
	changed()
