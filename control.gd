extends Control

@export var fade_duration: float = 1.0
@export var start_delay: float = 0.0

@onready var button: Button = $Play
@onready var label: Label = $Label

func _ready() -> void:
	# Start fully invisible
	button.modulate.a = 0.0
	label.modulate.a = 0.0

	_fade_in()


func _fade_in() -> void:
	if start_delay > 0.0:
		await get_tree().create_timer(start_delay).timeout

	var tween := create_tween()
	tween.set_parallel(true)  # both fade at the same time, not one after another
	tween.tween_property(button, "modulate:a", 1.0, fade_duration)
	tween.tween_property(label, "modulate:a", 1.0, fade_duration)




func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
