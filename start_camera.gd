extends Camera3D

@export var follow_strength: float = 0.3
@export var smoothing_speed: float = 4.0
@export var max_offset: float = 0.5

var base_position: Vector3
var base_rotation: Vector3
var target_offset: Vector3 = Vector3.ZERO
var current_offset: Vector3 = Vector3.ZERO

func _ready() -> void:
	base_position = position
	base_rotation = rotation


func _process(delta: float) -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()

	# Normalise mouse position to -1..1 range, centered on screen middle
	var normalised: Vector2 = Vector2(
		(mouse_pos.x / viewport_size.x) * 2.0 - 1.0,
		(mouse_pos.y / viewport_size.y) * 2.0 - 1.0
	)

	# Convert to a small 3D offset (X = left/right, Y = up/down, inverted since screen Y is flipped)
	target_offset = Vector3(normalised.x, -normalised.y, 0.0) * follow_strength
	target_offset = target_offset.limit_length(max_offset)

	# Smoothly interpolate toward the target so it doesn't snap
	current_offset = current_offset.lerp(target_offset, delta * smoothing_speed)

	position = base_position + current_offset
