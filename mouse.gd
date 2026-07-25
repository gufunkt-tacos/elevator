extends Control

func _ready() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null)  # hides nothing by itself, see note below
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
