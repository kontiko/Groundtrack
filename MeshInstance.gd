tool
extends MeshInstance

export var periapsis = 100.0 setget set_peri 
export var apoapsis = 100.0 setget set_apo
export (float) var semi_major setget set_major
export (float) var semi_minor setget set_minor
export (float) var e setget set_e
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var point_count = 360

# Called when the node enters the scene tree for the first time.
var is_ready = false
func _ready():
	is_ready = true
	update_Mesh()

func update_Mesh():
	if not is_ready:
		return
	var vertices = PoolVector3Array()
	for i in range(point_count):
		vertices.push_back(calc_vec(float(i)/point_count*2*PI))
		vertices.push_back(calc_vec(float(i+1)/point_count*2*PI))
	#vertices.push_back(Vector3(0, 0, 1))
	# Initialize the ArrayMesh.
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = vertices
	# Create the Mesh.
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	mesh = arr_mesh

func calc_vec(angle: float):
	var vec = Vector3(semi_major*sin(angle),0,semi_minor*cos(angle))
	vec = vec-Vector3(semi_major-periapsis,0,0)
	return vec
func set_peri(per):
	if per < apoapsis:
		periapsis = per
	else:
		periapsis = apoapsis
		apoapsis = per
	semi_major = (apoapsis+periapsis)/2
	e = 1-periapsis/semi_major
	semi_minor = semi_major*sqrt(1-pow(e,2))
	update_Mesh()

func set_apo(apo):
	if apo > periapsis:
		apoapsis = apo
	else:
		apoapsis = periapsis
		periapsis = apo
	semi_major = (apoapsis+periapsis)/2
	e = 1-periapsis/semi_major
	semi_minor = semi_major*sqrt(1-pow(e,2))
	update_Mesh()

func set_e(e):
	pass

func set_major(major):
	if major > semi_minor:
		semi_major = major
	else:
		semi_major = semi_minor
		semi_minor = major
	e = sqrt(1-pow(semi_minor,2)/pow(semi_major,2))
	periapsis = semi_major - e*semi_major
	apoapsis = semi_major + e*semi_major
	update_Mesh()

func set_minor(minor):
	if minor < semi_major:
		semi_minor = minor
	else:
		semi_minor = semi_major
		semi_major = minor
	e = sqrt(1-pow(semi_minor,2)/pow(semi_major,2))
	periapsis = semi_major - e*semi_major
	apoapsis = semi_major + e*semi_major
	update_Mesh()
