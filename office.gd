extends Node3D

@export var moving_environment: Node3D   # drag FinalOffice here
@export var handler: Node3D                # node with a start_fall bool
@export var acceleration: float = 5.0
@export var max_speed: float = 30.0
@export var loop_trigger_distance: float = 40.0
@export var teleport_distance: float = 40.0

var current_speed: float = 0.0
var distance_moved: float = 0.0
var was_falling: bool = false

func _process(delta: float) -> void:
	# Get start_fall safely from handler
	var start_fall: bool = false
	if handler and handler.get("start_fall") != null:
		start_fall = handler.start_fall
	else:
		return   # no handler or missing property – do nothing

	# Reset movement when start_fall becomes true
	if start_fall and not was_falling:
		current_speed = 0.0
		distance_moved = 0.0
	was_falling = start_fall

	if not start_fall:
		return

	# Accelerate and move only FinalOffice
	current_speed = min(current_speed + acceleration * delta, max_speed)
	var move_amount = current_speed * delta
	moving_environment.position.y += move_amount

	# Loop seamlessly
	distance_moved += move_amount
	if distance_moved >= loop_trigger_distance:
		moving_environment.position.y -= teleport_distance
		distance_moved -= loop_trigger_distance
