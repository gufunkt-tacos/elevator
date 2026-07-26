extends StaticBody3D

@onready var animation_player: AnimationPlayer = $"../Doors/AnimationPlayer"
@onready var button_sound: AudioStreamPlayer = $"../Doors/AudioStreamPlayer2"
@onready var display: Node3D = $"../ElevatorDisplay"



const START_NUMBER := 89
const END_NUMBER := 100
const DURATION := 7.0

@export var press_depth: float = 0.02
@export var press_duration: float = 0.1

@onready var button_root: Node3D = $CallButton_root

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

func cycle():
	var start_time = Time.get_ticks_msec() / 1000.0

	while true:
		var elapsed = (Time.get_ticks_msec() / 1000.0) - start_time
		var t = min(elapsed / DURATION, 1.0)

		var value = lerp(START_NUMBER, END_NUMBER, t)
		
		display.set_floor(value, display.Indicator.DOWN, true)

		if t >= 1.0:
			break

		await get_tree().process_frame

func press() -> void:
	if is_pressed:
		return
	is_pressed = true

	
	var tween := create_tween()
	tween.tween_property(button_root, "position:z", base_position.z - press_depth, press_duration * 0.4)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	tween.tween_property(button_root, "position:z", base_position.z, press_duration * 0.6)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

	await tween.finished
	
	print("Button pressed: ", name)
	
	await cycle()

	# Play animation
	animation_player.play("door_open")

	# --- 1. Play Sound ---
	# CRITICAL: Reset volume back to normal (0.0) before playing, 
	# otherwise the second time you press the button it will be muted!
	button_sound.volume_db = 0.0
	button_sound.play()

	# --- 2. Taper Off (Fade Out) Sound ---
	var fade_duration: float = 0.5 # How many seconds the fade-out takes (adjust to taste)
	
	if button_sound.stream != null:
		var track_length: float = button_sound.stream.get_length()
		var audio_tween := create_tween()
		
		if track_length > fade_duration:
			var wait_time: float = track_length - fade_duration
			# Tell the tween to wait, then fade the volume to -80 (silence)
			audio_tween.tween_interval(wait_time)
			audio_tween.tween_property(button_sound, "volume_db", -80.0, fade_duration)\
				.set_trans(Tween.TRANS_SINE)\
				.set_ease(Tween.EASE_IN)
		else:
			# If the sound effect is very short, just fade it out over its whole length
			audio_tween.tween_property(button_sound, "volume_db", -80.0, track_length)\
				.set_trans(Tween.TRANS_SINE)\
				.set_ease(Tween.EASE_IN)

	# --- 3. Button Visual Movement ---

	is_pressed = false
