class_name PaintableMesh
extends MeshInstance3D

@export var multimesh: MultiMeshInstance3D;
@export var ground_mesh: MeshInstance3D;

var shader_material: Material;
var grass_material: ShaderMaterial;
var ground_material: ShaderMaterial;
var size: Vector2;

func initialise():
	mesh.surface_set_material(0, shader_material);

	if multimesh:
		var grass_mesh: Mesh = multimesh.multimesh.mesh;
		grass_material = multimesh.material_override.duplicate();
		multimesh.material_override = grass_material;
		grass_material.set_shader_parameter("mesh_coords", Vector2(global_position.x, global_position.z));

	if ground_mesh and ground_mesh.mesh.material:
		ground_material = ground_mesh.mesh.material.duplicate();
		ground_mesh.mesh.material = ground_material;
		ground_material.set_shader_parameter("mesh_coords", Vector2(global_position.x, global_position.z));

func _physics_process(delta):
	if grass_material:
		grass_material.set_shader_parameter("player_position", Globals.player.global_position);
		grass_material.set_shader_parameter("mower_position", Globals.mower.global_position);
		
	if ground_material:
		ground_material.set_shader_parameter("player_position", Globals.player.global_position);

func set_paint_tex(tex: Texture):
	shader_material.set_shader_parameter("paint_texture", tex);

	if grass_material:
		if not grass_material.get_shader_parameter("initialised"):
			grass_material.set_shader_parameter("initialised", true);
			grass_material.set_shader_parameter("size", size);

		grass_material.set_shader_parameter("paint_texture", tex);
		
	if ground_material:
		if not ground_material.get_shader_parameter("initialised"):
			ground_material.set_shader_parameter("initialised", true);
			ground_material.set_shader_parameter("size", size);

		ground_material.set_shader_parameter("paint_texture", tex);

func make_unique():
	mesh = mesh.duplicate();
	ground_mesh.mesh = ground_mesh.mesh.duplicate()
