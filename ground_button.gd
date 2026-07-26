extends StaticBody3D
@export var elevator_node: Node3D

@onready var animation_player: AnimationPlayer = $"../../Doors/AnimationPlayer"

@export var press_depth: float = 0.02
@export var press_duration: float = 0.1

@onready var button_root: Node3D = $Node3D

var is_pressed: bool = false
var base_position: Vector3
var mesh_instances: Array[MeshInstance3D] = []


func _ready() -> void:
	add_to_group("buttons")
	base_position = button_root.position
	_collect_meshes(button_root)
	_generate_collision_shape()


func _collect_meshes(node: Node) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			mesh_instances.append(child)
		_collect_meshes(child)  # recurse in case meshes are nested deeper


func _generate_collision_shape() -> void:
	var combined_aabb: AABB
	var first := true

	for mesh in mesh_instances:
		var mesh_aabb: AABB = mesh.get_aabb()
		mesh_aabb = mesh.transform * mesh_aabb
		if first:
			combined_aabb = mesh_aabb
			first = false
		else:
			combined_aabb = combined_aabb.merge(mesh_aabb)

	var box_shape := BoxShape3D.new()
	box_shape.size = combined_aabb.size

	var collision_shape := CollisionShape3D.new()
	collision_shape.shape = box_shape
	collision_shape.position = button_root.position + combined_aabb.get_center()

	add_child(collision_shape)


func press() -> void:
	if is_pressed:
		return
	is_pressed = true

	print("Button pressed: ", name)


	# --- 3. Button Visual Movement ---
	var tween := create_tween()
	tween.tween_property(button_root, "position:z", base_position.z - press_depth, press_duration * 0.4)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	tween.tween_property(button_root, "position:z", base_position.z, press_duration * 0.6)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

	await tween.finished


	animation_player.play("broken_doors")
	await animation_player.animation_finished
	animation_player.play("loop")
	
	elevator_node.is_active = true

	
