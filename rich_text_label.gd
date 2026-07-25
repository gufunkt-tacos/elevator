extends RichTextLabel

@export var characters_per_second: float = 30.0
@export var hide_when_done_delay: float = 2.0  # 0 = never auto-hide

var full_text: String = ""
var char_timer: float = 0.0
var is_typing: bool = false


func _ready() -> void:
	bbcode_enabled = true
	visible_characters = 0
	visible = false


func _process(delta: float) -> void:
	if is_typing:
		char_timer += characters_per_second * delta
		visible_characters = int(char_timer)

		if visible_characters >= get_total_character_count():
			visible_characters = -1  # -1 means "show everything" in RichTextLabel
			is_typing = false
			if hide_when_done_delay > 0.0:
				await get_tree().create_timer(hide_when_done_delay).timeout
				visible = false


func show_subtitle(new_text: String) -> void:
	full_text = new_text
	text = new_text
	char_timer = 0.0
	visible_characters = 0
	visible = true
	is_typing = true


func skip_to_end() -> void:
	if is_typing:
		visible_characters = -1
		is_typing = false
