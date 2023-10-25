extends Spatial

var vertex_array  :PoolVector3Array
var index_array   :PoolIntArray

var marker := load("res://marker.tscn")

var mean = 0.0
var covariance = Basis(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO)

var eigenvalue_1 = 0.0
var eigenvalue_2 = 0.0
var eigenvalue_3 = 0.0

var eigenvector_1 = 0.0
var eigenvector_2 = 0.0
var eigenvector_3 = 0.0

var max_A = -INF
var min_A = INF
var max_B = -INF
var min_B = INF
var max_C = -INF
var min_C = INF


func _ready():
	var data_structure = $shape.mesh.surface_get_arrays(0)
	vertex_array = data_structure[0]
	index_array  = data_structure[8]

	# add markers indicating vertices positions
	for i in vertex_array.size():
		var new_marker = marker.instance()
		$shape/vertices.add_child(new_marker)
		new_marker.translation = vertex_array[i]

	calculate_mean()
	print ("Mean: ")
	print (mean)
	# add marker indicating mean position
	var new_marker = marker.instance()
	$shape.add_child(new_marker)
	new_marker.translation = mean
	new_marker.material_override = new_marker.material_override.duplicate()
	new_marker.material_override.set("albedo_color", Color.red)
	
	calculate_covariance_matrix()
	print ("Covariance: ")
	print (covariance.x)
	print (covariance.y)
	print (covariance.z)
	calculate_eigenvalues()
	
	print ("Eigenvalues: ")
	print (eigenvalue_1, " ", eigenvalue_2, " ", eigenvalue_3 )
	
	calculate_eigenvectors()
	print ("Eigenvectors: ")
	print ( eigenvector_1 )
	print ( eigenvector_2 )
	print ( eigenvector_3 )
	
	calculate_axis_extent()
	
	draw_axis()
	draw_bounding_box()
	draw_wireframe()

func calculate_mean():
	# mean position of verices
	var sum = Vector3.ZERO
	for i in vertex_array.size():
		sum += vertex_array[i]

	mean = sum / vertex_array.size()

func calculate_covariance_matrix():
	var vector_x = Vector3.ZERO
	var vector_y = Vector3.ZERO
	var vector_z = Vector3.ZERO
	
	for i in vertex_array.size():
		print (vertex_array[i])
		vector_x.x += pow(vertex_array[i].x - mean.x, 2)
		vector_x.y += (vertex_array[i].x - mean.x) * (vertex_array[i].y - mean.y)
		vector_x.z += (vertex_array[i].x - mean.x) * (vertex_array[i].z - mean.z)

		vector_y.x += (vertex_array[i].x - mean.x) * (vertex_array[i].y - mean.y)
		vector_y.y += pow(vertex_array[i].y - mean.y, 2)
		vector_y.z += (vertex_array[i].y - mean.y) * (vertex_array[i].z - mean.z)
		
		vector_z.x += (vertex_array[i].x - mean.x) * (vertex_array[i].z - mean.z)
		vector_z.y += (vertex_array[i].y - mean.y) * (vertex_array[i].z - mean.z)
		vector_z.z += pow(vertex_array[i].z - mean.z, 2)
		
	covariance = Basis(vector_x / vertex_array.size(), vector_y / vertex_array.size(), vector_z / vertex_array.size())

func calculate_eigenvalues():
	# Compute the eigenvalues for real symmetric 3x3 matrix
	# code based on https://en.wikipedia.org/wiki/Eigenvalue_algorithm
	var p1 = pow(covariance[0][1],2) + pow(covariance[0][2],2) + pow(covariance[1][2],2)
	
	if p1 == 0:
		eigenvalue_1 = covariance[0][0]
		eigenvalue_2 = covariance[1][1]
		eigenvalue_3 = covariance[2][2]
	else:
		var q = (covariance[0][0] + covariance[1][1] + covariance[2][2]) / 3.0
		var p2 = pow(covariance[0][0] - q, 2) + pow(covariance[1][1] - q, 2) + pow(covariance[2][2] - q, 2) + 2 * p1
		var p = sqrt(p2 / 6)

		# var B = ( 1 / p ) * ( covariance + identity )
		var identity =  Basis.IDENTITY
		identity.x *= q
		identity.y *= q
		identity.z *= q
		var B = covariance
		B.x -= identity.x
		B.y -= identity.y
		B.z -= identity.z
		B.x *= ( 1 / p )
		B.y *= ( 1 / p )
		B.z *= ( 1 / p )

		var r = B.determinant() / 2

		var phi = 0.0
		if (r <= -1):
			phi = PI / 3
		elif (r >= 1):
			phi = 0
		else:
			phi = acos(r) / 3

		# the eigenvalues satisfy eig3 <= eig2 <= eig1
		eigenvalue_1 = q + 2 * p * cos(phi)
		eigenvalue_3 = q + 2 * p * cos(phi + (2*PI/3))
		eigenvalue_2 = 3 * q - eigenvalue_1 - eigenvalue_3 # since trace(A) = eig1 + eig2 + eig3

func calculate_eigenvectors():

	var matrix = covariance
	if eigenvalue_1 != 1 :
		matrix.x.x -=  eigenvalue_1
		matrix.y.y -=  eigenvalue_1
		matrix.z.z -=  eigenvalue_1
		eigenvector_1 = get_eigenvector( matrix )
	else:
		eigenvector_1 = covariance.x
	
	if eigenvalue_2 != 1 :
		matrix = covariance
		matrix.x.x -=  eigenvalue_2
		matrix.y.y -=  eigenvalue_2
		matrix.z.z -=  eigenvalue_2
		eigenvector_2 = get_eigenvector( matrix )
	else:
		eigenvector_2 = covariance.y
		
	if eigenvalue_3 !=1 :
		matrix = covariance
		matrix.x.x -=  eigenvalue_3
		matrix.y.y -=  eigenvalue_3
		matrix.z.z -=  eigenvalue_3
		eigenvector_3 = get_eigenvector( matrix )
	else:
		eigenvector_3 = covariance.z

func get_eigenvector( matrix ):
	# Compute the eigenvector for real symmetric 3x3 matrix
	# based on code from: https://github.com/nrutkowski1/eigenvectors_and_eigenvalues/blob/master/eig.py 
	var r0xr1 = Vector3(matrix.x[1] * matrix.y[2] - matrix.x[2] * matrix.y[1], 
						matrix.x[2] * matrix.y[0] - matrix.x[0] * matrix.y[2],
						matrix.x[0] * matrix.y[1] - matrix.x[1] * matrix.y[0])
	var r0xr2 = Vector3(matrix.x[1] * matrix.z[2] - matrix.x[2] * matrix.z[1], 
						matrix.x[2] * matrix.z[0] - matrix.x[0] * matrix.z[2],
						matrix.x[0] * matrix.z[1] - matrix.x[1] * matrix.z[0])
	var r1xr2 = Vector3(matrix.y[1] * matrix.z[2] - matrix.y[2] * matrix.z[1], 
						matrix.y[2] * matrix.z[0] - matrix.y[0] * matrix.z[2],
						matrix.y[0] * matrix.z[1] - matrix.y[1] * matrix.z[0])

	var d0 = r0xr1.x * r0xr1.x + r0xr1.y * r0xr1.y + r0xr1.z * r0xr1.z
	var d1 = r0xr2.x * r0xr2.x + r0xr2.y * r0xr2.y + r0xr2.z * r0xr2.z
	var d2 = r1xr2.x * r1xr2.x + r1xr2.y * r1xr2.y + r1xr2.z * r1xr2.z
	var imax = 0
	var dmax = d0

	if d1 > dmax:
		dmax = d1
		imax = 1
	if d2 > dmax:
		imax = 2
	if imax == 0:
		return r0xr1 / sqrt(d0)
	if imax == 1:
		return r0xr2 / sqrt(d1)
	if imax == 2:
		return r1xr2 / sqrt(d2)

func calculate_axis_extent():
	# calculte farther points along eigenvectors gving bounding box walls distance
	for i in vertex_array.size():
		if vertex_array[i].dot(eigenvector_1) > max_A:
			max_A = vertex_array[i].dot(eigenvector_1)
		if vertex_array[i].dot(eigenvector_1) < min_A:
			min_A = vertex_array[i].dot(eigenvector_1)

		if vertex_array[i].dot(eigenvector_2) > max_B:
			max_B = vertex_array[i].dot(eigenvector_2)
		if vertex_array[i].dot(eigenvector_2) < min_B:
			min_B = vertex_array[i].dot(eigenvector_2)

		if vertex_array[i].dot(eigenvector_3) > max_C:
			max_C = vertex_array[i].dot(eigenvector_3)
		if vertex_array[i].dot(eigenvector_3) < min_C:
			min_C = vertex_array[i].dot(eigenvector_3)

func draw_wireframe():
	$shape/wireframe.begin( Mesh.PRIMITIVE_LINES, null )
	$shape/wireframe.set_color(Color.white)
	for i in index_array.size()/3:
		$shape/wireframe.add_vertex( vertex_array[index_array[i*3]] )
		$shape/wireframe.add_vertex( vertex_array[index_array[i*3+1]] )
#		$shape/wireframe.add_vertex( vertex_array[index_array[i*3+1]] )
		$shape/wireframe.add_vertex( vertex_array[index_array[i*3+2]] )
		$shape/wireframe.add_vertex( vertex_array[index_array[i*3+2]] )
		$shape/wireframe.add_vertex( vertex_array[index_array[i*3]] )
	$shape/wireframe.end()

func draw_axis():
	$shape/axis.begin( Mesh.PRIMITIVE_LINES, null )
	$shape/axis.add_vertex( eigenvector_1 * min_A )
	$shape/axis.add_vertex( eigenvector_1 * max_A )
	$shape/axis.add_vertex( eigenvector_2 * min_B )
	$shape/axis.add_vertex( eigenvector_2 * max_B )
	$shape/axis.add_vertex( eigenvector_3 * min_C )
	$shape/axis.add_vertex( eigenvector_3 * max_C )
	$shape/axis.end()

func draw_bounding_box():
	$shape/bounding_box.begin( Mesh.PRIMITIVE_TRIANGLES, null )
	$shape/bounding_box.set_normal( eigenvector_1 )
	$shape/bounding_box.add_vertex( eigenvector_1 * max_A + eigenvector_2 * max_B + eigenvector_3 * min_C )
	$shape/bounding_box.add_vertex( eigenvector_1 * max_A + eigenvector_2 * max_B + eigenvector_3 * max_C )
	$shape/bounding_box.add_vertex( eigenvector_1 * max_A + eigenvector_2 * min_B + eigenvector_3 * max_C )
	$shape/bounding_box.add_vertex( eigenvector_1 * max_A + eigenvector_2 * max_B + eigenvector_3 * min_C )
	$shape/bounding_box.add_vertex( eigenvector_1 * max_A + eigenvector_2 * min_B + eigenvector_3 * max_C )
	$shape/bounding_box.add_vertex( eigenvector_1 * max_A + eigenvector_2 * min_B + eigenvector_3 * min_C )
	
	$shape/bounding_box.set_normal( -eigenvector_1 )
	$shape/bounding_box.add_vertex( eigenvector_1 * min_A + eigenvector_2 * min_B + eigenvector_3 * min_C )
	$shape/bounding_box.add_vertex( eigenvector_1 * min_A + eigenvector_2 * min_B + eigenvector_3 * max_C )
	$shape/bounding_box.add_vertex( eigenvector_1 * min_A + eigenvector_2 * max_B + eigenvector_3 * max_C )
	$shape/bounding_box.add_vertex( eigenvector_1 * min_A + eigenvector_2 * min_B + eigenvector_3 * min_C )
	$shape/bounding_box.add_vertex( eigenvector_1 * min_A + eigenvector_2 * max_B + eigenvector_3 * max_C )
	$shape/bounding_box.add_vertex( eigenvector_1 * min_A + eigenvector_2 * max_B + eigenvector_3 * min_C )
	
	$shape/bounding_box.set_normal( eigenvector_2 )
	$shape/bounding_box.add_vertex( eigenvector_2 * max_B + eigenvector_1 * max_A + eigenvector_3 * min_C )
	$shape/bounding_box.add_vertex( eigenvector_2 * max_B + eigenvector_1 * min_A + eigenvector_3 * max_C )
	$shape/bounding_box.add_vertex( eigenvector_2 * max_B + eigenvector_1 * max_A + eigenvector_3 * max_C )
	$shape/bounding_box.add_vertex( eigenvector_2 * max_B + eigenvector_1 * min_A + eigenvector_3 * max_C )
	$shape/bounding_box.add_vertex( eigenvector_2 * max_B + eigenvector_1 * max_A + eigenvector_3 * min_C )
	$shape/bounding_box.add_vertex( eigenvector_2 * max_B + eigenvector_1 * min_A + eigenvector_3 * min_C )

	$shape/bounding_box.set_normal( -eigenvector_2 )
	$shape/bounding_box.add_vertex( eigenvector_2 * min_B + eigenvector_1 * min_A + eigenvector_3 * min_C )
	$shape/bounding_box.add_vertex( eigenvector_2 * min_B + eigenvector_1 * max_A + eigenvector_3 * max_C )
	$shape/bounding_box.add_vertex( eigenvector_2 * min_B + eigenvector_1 * min_A + eigenvector_3 * max_C )
	$shape/bounding_box.add_vertex( eigenvector_2 * min_B + eigenvector_1 * min_A + eigenvector_3 * min_C )
	$shape/bounding_box.add_vertex( eigenvector_2 * min_B + eigenvector_1 * max_A + eigenvector_3 * min_C )
	$shape/bounding_box.add_vertex( eigenvector_2 * min_B + eigenvector_1 * max_A + eigenvector_3 * max_C )

	$shape/bounding_box.set_normal( eigenvector_3 )
	$shape/bounding_box.add_vertex( eigenvector_3 * max_C + eigenvector_1 * max_A + eigenvector_2 * min_B )
	$shape/bounding_box.add_vertex( eigenvector_3 * max_C + eigenvector_1 * max_A + eigenvector_2 * max_B )
	$shape/bounding_box.add_vertex( eigenvector_3 * max_C + eigenvector_1 * min_A + eigenvector_2 * max_B )
	$shape/bounding_box.add_vertex( eigenvector_3 * max_C + eigenvector_1 * max_A + eigenvector_2 * min_B )
	$shape/bounding_box.add_vertex( eigenvector_3 * max_C + eigenvector_1 * min_A + eigenvector_2 * max_B )
	$shape/bounding_box.add_vertex( eigenvector_3 * max_C + eigenvector_1 * min_A + eigenvector_2 * min_B )

	$shape/bounding_box.set_normal( -eigenvector_3 )
	$shape/bounding_box.add_vertex( eigenvector_3 * min_C + eigenvector_1 * max_A + eigenvector_2 * max_B )
	$shape/bounding_box.add_vertex( eigenvector_3 * min_C + eigenvector_1 * min_A + eigenvector_2 * min_B )
	$shape/bounding_box.add_vertex( eigenvector_3 * min_C + eigenvector_1 * min_A + eigenvector_2 * max_B )
	$shape/bounding_box.add_vertex( eigenvector_3 * min_C + eigenvector_1 * min_A + eigenvector_2 * min_B )
	$shape/bounding_box.add_vertex( eigenvector_3 * min_C + eigenvector_1 * max_A + eigenvector_2 * max_B )
	$shape/bounding_box.add_vertex( eigenvector_3 * min_C + eigenvector_1 * max_A + eigenvector_2 * min_B )
	$shape/bounding_box.end()

func _on_Wireframe_toggled(button_pressed):
	$shape/wireframe.visible = button_pressed

func _on_Vertices_toggled(button_pressed):
	$shape/vertices.visible = button_pressed

func _on_Model_faces_toggled(button_pressed):
	$shape.material_override.set("flags_transparent", button_pressed) 
	$UI/Model_opacity.editable = button_pressed

func _on_Model_opacity_value_changed(value):
	$shape.material_override.set("albedo_color", Color(1,1,1,float($UI/Model_faces.pressed) * $UI/Model_opacity.value ) )

func _on_BoundingBox_toggled(button_pressed):
	$shape/bounding_box.material_override.set("flags_transparent", button_pressed) 
	$UI/BoundingBox_opacity.editable = button_pressed

func _on_BoundingBox_opacity_value_changed(value):
	$shape/bounding_box.material_override.set("albedo_color", Color(0,1,1,value) )
