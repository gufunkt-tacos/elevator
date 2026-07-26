extends Node3D

@export var display_color: Color = Color(1.0, 0.15, 0.05)

@onready var digit_hundreds: MeshInstance3D = $Digit_Hundreds
@onready var digit_tens: MeshInstance3D = $Digit_Tens
@onready var digit_ones: MeshInstance3D = $Digit_Ones
@onready var arrow: MeshInstance3D = $Arrow

enum Indicator { UP, DOWN, MINUS }


func _ready() -> void:
	set_display_color(display_color)


func set_floor(floor_number: int, indicator: Indicator, moving: bool = true) -> void:
	var clamped: int = clamp(floor_number, 0, 999)
	var hundreds: int = clamped / 100
	var tens: int = (clamped / 10) % 10
	var ones: int = clamped % 10

	_set_digit(digit_hundreds, hundreds if hundreds > 0 else -1)
	_set_digit(digit_tens, tens if (hundreds > 0 or tens > 0) else -1)
	_set_digit(digit_ones, ones)

	_set_arrow(indicator, moving)


func set_display_color(color: Color) -> void:
	display_color = color
	for mesh in [digit_hundreds, digit_tens, digit_ones, arrow]:
		var mat := mesh.get_surface_override_material(0) as ShaderMaterial
		if mat:
			mat.set_shader_parameter("display_color", Vector3(color.r, color.g, color.b))


func _set_digit(mesh: MeshInstance3D, value: int) -> void:
	var mat := mesh.get_surface_override_material(0) as ShaderMaterial
	if mat:
		mat.set_shader_parameter("digit", value)


func _set_arrow(indicator: Indicator, active: bool) -> void:
	var mat := arrow.get_surface_override_material(0) as ShaderMaterial
	if mat:
		mat.set_shader_parameter("indicator_mode", indicator)
		mat.set_shader_parameter("arrow_active", active)
