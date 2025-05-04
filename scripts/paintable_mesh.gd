class_name PaintableMesh
extends MeshInstance3D

@export var multimesh: MultiMeshInstance3D;

var shader_material: ShaderMaterial;
var grass_material: ShaderMaterial;

func _ready():
	if get_active_material(0):
		shader_material = get_active_material(0).duplicate()
		mesh.surface_set_material(0, shader_material)	
		
	if multimesh:
		var grass_mesh: Mesh = multimesh.multimesh.mesh
		grass_material = multimesh.material_override;
		grass_material.set_shader_parameter("mesh_coords", Vector2(global_position.x, global_position.z))
	
func set_paint_tex(tex: Texture):
	shader_material.set_shader_parameter("paint_texture", tex)

	if grass_material:
		if not grass_material.get_shader_parameter("initialised"):
			grass_material.set_shader_parameter("initialised", true);

		grass_material.set_shader_parameter("paint_texture", tex)
