extends CanvasLayer

@onready var rect = $ColorRect
var fade_active = false

func fade_to_scene(next_scene: String, duration: float = 1.0) -> void:
	if fade_active:
		return
	fade_active = true

	rect.modulate.a = 0
	rect.visible = true

	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 1.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(Callable(self, "_change_scene").bind(next_scene))

func _change_scene(next_scene: String) -> void:
	get_tree().change_scene_to_file(next_scene)

	rect.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(Callable(self, "_fade_finished"))

func _fade_finished():
	fade_active = false

func fade_and_quit(duration: float = 1.0) -> void:
	# Make sure we don’t run multiple times
	if fade_active:
		return
	fade_active = true
	rect.modulate.a = 0
	rect.visible = true
	var tween = create_tween()
	# Fade to black
	tween.tween_property(rect, "modulate:a", 1.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	# After fade finishes, quit the game
	tween.tween_callback(Callable(self, "_quit_game"))
	
func _quit_game():
	get_tree().quit()
