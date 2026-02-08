extends Area2D

var task5_fade_started = false
var player_inside = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (player_inside and Input.is_action_just_pressed("interact")):
		task5_fade_started = true
		Fade.fade_to_scene("res://Scenes/Maps/house.tscn", 1.0)

func _on_body_entered(body: CharacterBody2D) -> void:
	if body is CharacterBody2D:
		player_inside = true


func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_inside = false
