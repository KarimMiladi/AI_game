extends Area2D

var player_inside = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (player_inside and Input.is_action_just_pressed("interact") and GameManager.task == 2):
		print("wires cut")

func _on_body_entered(body: CharacterBody2D) -> void:
	print(body)
	if body is CharacterBody2D:
		player_inside = true

func _on_body_exited(body: Node2D) -> void:
	print(body)
	if body is CharacterBody2D:
		player_inside = false
