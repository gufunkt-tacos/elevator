extends AnimatableBody3D

@export var use_convex_collision: bool = true

var mesh_instances: Array[MeshInstance3D] = []


func _ready() -> void:
	_collect_meshes(self)

	if mesh_instances.is_empty():
		print("No meshes found in ", name)
		return

	_generate_collision()


func _collect_meshes(node: Node) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			mesh_instances.append(child)

		_collect_meshes(child)


func _generate_collision() -> void:
	for mesh in mesh_instances:
		var shape: Shape3D

		if use_convex_collision:
			shape = mesh.mesh.create_convex_shape()
		else:
			shape = mesh.mesh.create_trimesh_shape()

		var collision := CollisionShape3D.new()
		collision.shape = shape
		collision.transform = mesh.transform

		add_child(collision)

	print("Generated collision for ", name)
