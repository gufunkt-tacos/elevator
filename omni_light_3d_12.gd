extends OmniLight3D

@export var flash_energy: float = 8.0
@export var min_delay: float = 4.0
@export var max_delay: float = 12.0
@export var flash_duration: float = 0.15
@export var double_flash_chance: float = 0.4
@export var thunder_min_delay: float = 0.3
@export var thunder_max_delay: float = 1.5
@export var thunder_volume_db: float = -10.0
@export var thunder_lead_time: float = 0.0
@export var initial_flash_delay: float = 3.0

@export var thunder_sounds: Array[AudioStream] = []
@onready var thunder_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready() -> void:
	light_energy = 0.0
	visible = false

	add_child(thunder_player)
	thunder_player.volume_db = thunder_volume_db

	_schedule_initial_flash()


func _schedule_initial_flash() -> void:
	await get_tree().create_timer(initial_flash_delay).timeout
	_do_flash()


func _schedule_next_flash() -> void:
	var wait_time: float = randf_range(min_delay, max_delay)
	await get_tree().create_timer(wait_time).timeout
	_do_flash()


func _do_flash() -> void:
	visible = true

	await _flicker()

	if randf() < double_flash_chance:
		await get_tree().create_timer(randf_range(0.05, 0.2)).timeout
		await _flicker()

	visible = false
	light_energy = 0.0

	_play_thunder()

	_schedule_next_flash()


func _flicker() -> void:
	var tween := create_tween()
	tween.tween_property(self, "light_energy", flash_energy, flash_duration * 0.2)
	tween.tween_property(self, "light_energy", flash_energy * 0.3, flash_duration * 0.3)
	tween.tween_property(self, "light_energy", flash_energy, flash_duration * 0.2)
	tween.tween_property(self, "light_energy", 0.0, flash_duration * 0.3)
	await tween.finished


func _play_thunder() -> void:
	if thunder_sounds.is_empty():
		return

	var delay: float = max(0.0, randf_range(thunder_min_delay, thunder_max_delay) - thunder_lead_time)
	await get_tree().create_timer(delay).timeout

	thunder_player.stream = thunder_sounds[randi() % thunder_sounds.size()]
	thunder_player.pitch_scale = randf_range(0.9, 1.1)
	thunder_player.play()
