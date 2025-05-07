extends Node

# Reference: https://alfredbaudisch.com/blog/gamedev/godot-engine/godot-engine-in-game-splat-map-texture-painting-dirt-removal-effect/
# Slightly modified for use in Godot 4

class_name PointToUVConverter

var meshtool
var mesh
var mesh_instance

var transform_vertex_to_global = true

var _face_count := 0
var _world_normals := PackedVector3Array()
var _world_vertices := []
var _local_face_vertices := []

func set_mesh(_mesh_instance: MeshInstance3D):
	mesh_instance = _mesh_instance
	mesh = _mesh_instance.mesh
	
	
	var array_mesh: ArrayMesh = ArrayMesh.new()
	if mesh is ArrayMesh:
		array_mesh = mesh
	else:
		array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh.get_mesh_arrays())

	meshtool = MeshDataTool.new()
	meshtool.create_from_surface(array_mesh, 0)
	
	_face_count = meshtool.get_face_count()
	_world_normals.resize(_face_count)
  
	_load_mesh_data()

func _load_mesh_data():
	for idx in range(_face_count):
		_world_normals[idx] = mesh_instance.global_transform.basis * (meshtool.get_face_normal(idx))
	
		var fv1 = meshtool.get_face_vertex(idx, 0)
		var fv2 = meshtool.get_face_vertex(idx, 1)
		var fv3 = meshtool.get_face_vertex(idx, 2)
		
		_local_face_vertices.append([fv1, fv2, fv3])
		
		_world_vertices.append([
			mesh_instance.global_transform * (meshtool.get_vertex(fv1)),
			mesh_instance.global_transform * (meshtool.get_vertex(fv2)),
			mesh_instance.global_transform * (meshtool.get_vertex(fv3)),
		])
	
func get_face(point, normal, epsilon = 0.2) -> Variant:
	for idx in range(_face_count):
		var world_normal = _world_normals[idx]
	
		if !equals_with_epsilon(world_normal, normal, epsilon):
			continue
		  
		var vertices = _world_vertices[idx]
		
		var bc = is_point_in_triangle(point, vertices[0], vertices[1], vertices[2])
		if bc:
			return [idx, vertices, bc]
		  
	return null
	
func get_faces_to_update(point, normal, transform = true, epsilon = 0.2):
	transform_vertex_to_global = transform;
	var faces: Array = get_faces_overlapping_sphere(point, normal, 0.1);
	var faces_data: Array = [];

	for idx in faces:
		var world_normal = _world_normals[idx];
	
		if !equals_with_epsilon(world_normal, normal, epsilon):
			continue;
		  
		var vertices = _world_vertices[idx];
		
		var bc = is_point_in_triangle(point, vertices[0], vertices[1], vertices[2]);
		if bc:
			faces_data.append({
				"idx": idx,
				"vertices": vertices,
				"bc": bc
			});

	return faces_data;

func get_uv_coords(point, normal, transform = true):
	transform_vertex_to_global = transform

	var face = get_face(point, normal)

	if face == null:
		return null
	
	var bc = face[2]
#
	var uv1 = meshtool.get_vertex_uv(_local_face_vertices[face[0]][0])
	var uv2 = meshtool.get_vertex_uv(_local_face_vertices[face[0]][1])
	var uv3 = meshtool.get_vertex_uv(_local_face_vertices[face[0]][2])

	return (uv1 * bc.x) + (uv2 * bc.y) + (uv3 * bc.z)
	
func get_face_uvs(idx: int) -> Array:
	var uv1 = meshtool.get_vertex_uv(_local_face_vertices[idx][0])
	var uv2 = meshtool.get_vertex_uv(_local_face_vertices[idx][1])
	var uv3 = meshtool.get_vertex_uv(_local_face_vertices[idx][2])
	
	return [uv1, uv2, uv3];

func equals_with_epsilon(v1, v2, epsilon):
	if (v1.distance_to(v2) < epsilon):
		return true
	return false
  
func cart2bary(p : Vector3, a : Vector3, b : Vector3, c: Vector3) -> Vector3:
	var v0 := b - a
	var v1 := c - a
	var v2 := p - a
	var d00 := v0.dot(v0)
	var d01 := v0.dot(v1)
	var d11 := v1.dot(v1)
	var d20 := v2.dot(v0)
	var d21 := v2.dot(v1)
	var denom := d00 * d11 - d01 * d01
	var v = (d11 * d20 - d01 * d21) / denom
	var w = (d00 * d21 - d01 * d20) / denom
	var u = 1.0 - v - w
	return Vector3(u, v, w)

func transfer_point(from : Basis, to : Basis, point : Vector3) -> Vector3:
	return (to * from.inverse()) * (point)
  
func bary2cart(a : Vector3, b : Vector3, c: Vector3, barycentric: Vector3) -> Vector3:
	return barycentric.x * a + barycentric.y * b + barycentric.z * c
  
func is_point_in_triangle(point, v1, v2, v3):
	var bc = cart2bary(point, v1, v2, v3)  
  
	if (bc.x < 0 or bc.x > 1) or (bc.y < 0 or bc.y > 1) or (bc.z < 0 or bc.z > 1):
		return null
	
	return bc
	
func get_faces_overlapping_sphere(point, normal, radius) -> Array:
	var hit_face = get_face(point, normal);
	var faces: Array;
	
	if not hit_face:
		return [];
	
	for idx in range(_face_count):
		var vertices = _world_vertices[idx];
		
		var line_1 = is_line_intersecting_sphere(vertices[0], vertices[1], point, radius);
		var line_2 = is_line_intersecting_sphere(vertices[0], vertices[2], point, radius);
		var line_3 = is_line_intersecting_sphere(vertices[1], vertices[2], point, radius);
		
		if line_1 or line_2 or line_3:
			faces.append(idx);
	
	if not faces.has(hit_face[0]):
		faces.append(hit_face[0])

	return faces;
	
#func is_line_intersecting_circle(a: Vector2, b: Vector2, c: Vector2, r: float):
	#a.x -= c.x;
	#a.y -= c.y;
	#b.x -= c.x;
	#b.y -= c.y;
#
	#var a_eq: float = pow(b.x - a.x,2) + pow(b.y - a.y, 2);
	#var b_eq: float = 2 * (a.x*(b.x - a.x) + a.y * (b.y - a.y));
	#var c_eq: float = pow(a.x, 2) + pow(a.y, 2) - pow(r, 2);
#
	#var disc: float = pow(b_eq, 2) - 4 * a_eq * c_eq;
#
	#if disc <= 0:
		#return false;
#
	#var sqrtdisc = sqrt(disc);
	#var t1: float = (-b_eq + sqrtdisc) / (2 * a_eq);
	#var t2: float = (-b_eq - sqrtdisc) / (2 * a_eq);
#
	#if (0 < t1 && t1 < 1) or (0 < t2 && t2 < 1):
		#return true;
#
	#return false;

func is_line_intersecting_sphere(point_a: Vector3, point_b: Vector3, sphere_point: Vector3, sphere_radius: float):
	var delta_x: float = point_b.x - point_a.x;
	var delta_y: float = point_b.y - point_a.y;
	var delta_z: float = point_b.z - point_a.z;

	var a: float = delta_x * delta_x + delta_y * delta_y + delta_z * delta_z;
	var b: float = 2.0 * (delta_x * (point_a.x - sphere_point.x) + delta_y * (point_a.y - sphere_point.y) + delta_z * (point_a.z - sphere_point.z));
	var c: float = sphere_point.x * sphere_point.x + sphere_point.y * sphere_point.y + sphere_point.z * sphere_point.z + point_a.x * point_a.x + point_a.y * point_a.y + point_a.z * point_a.z - 2.0 * (sphere_point.x * point_a.x + sphere_point.y * point_a.y + sphere_point.z * point_a.z) - sphere_radius * sphere_radius;

	var test: float = b * b - 4.0 * a * c;

	if test >= 0.0:
		var u: float = (-b - sqrt(test)) / (2.0 * a);
		var hit_point: Vector3 = point_a + u * (point_b - point_a);
		return hit_point;

	return false;
