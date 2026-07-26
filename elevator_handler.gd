extends Node3D
@export var office_node: Node3D

var is_active: bool = false
var start_fall: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_active:
		start_fall = true
