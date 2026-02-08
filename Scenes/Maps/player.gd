extends CharacterBody2D

const SPEED = 400.0
var task5_fade_started = false

func _physics_process(delta: float) -> void:
	if GameManager.task == 3 and not task5_fade_started:
		task5_fade_started = true
		Fade.fade_to_scene("res://Scenes/Maps/house_dark.tscn", 1.0)
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("left", "right","top","bot")
	if direction:
		velocity = direction * SPEED
		if(direction.x == 1):
			$AnimatedSprite2D.play("right")
		elif(direction.x == -1):
			$AnimatedSprite2D.play("left")
		elif(direction.y == -1):
			$AnimatedSprite2D.play("top")
		elif(direction.y == 1):
			$AnimatedSprite2D.play("bot")
		else:
			$AnimatedSprite2D.play("idle")
	else:
		$AnimatedSprite2D.play("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()


func _on_book_2_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
