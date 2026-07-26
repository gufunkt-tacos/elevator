extends Node3D
#
@onready var display: Node3D = $"../../Elevator_root/ElevatorDisplay"
#
#var test_floor: int = 1
#var seconds_per_number: float = 0.3
#
#
func _ready() -> void:
	display.set_floor(89, display.Indicator.DOWN, true)
#
#
#func _count_up() -> void:
	#while true:
		#display.set_floor(test_floor, display.Indicator.UP, true)
		#await get_tree().create_timer(seconds_per_number).timeout
#
		#test_floor += 1
		#if test_floor > 999:
			#test_floor = 1
