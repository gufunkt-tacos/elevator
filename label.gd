extends Label

@export var rise_amount: float = 6.0
@export var rise_duration: float = 2.0
@export var jostle_strength: float = 2.0
@export var jostle_speed: float = 1.5

var base_position: Vector2
var time_offset: float

func _ready() -> void:
	base_position = position
	time_offset = randf() * 100.0  # so multiple labels don't jostle in sync

	_rise_in()


func _rise_in() -> void:
	position.y = base_position.y + rise_amount

	var tween := create_tween()
	tween.tween_property(self, "position:y", base_position.y, rise_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	var t: float = Time.get_ticks_msec() / 1000.0 + time_offset

	var jostle_x: float = sin(t * jostle_speed) * jostle_strength
	var jostle_y: float = cos(t * jostle_speed * 1.3) * jostle_strength * 0.6

	position = Vector2(base_position.x + jostle_x, base_position.y + jostle_y)
