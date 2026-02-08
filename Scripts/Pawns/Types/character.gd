class_name Character
extends Pawn

@export var speed: float = 1.5

var move_tween: Tween
var is_moving: bool = false
var is_talking: bool = false

@onready var chara_skin: Sprite2D = $Skin
@onready var Grid: Node2D = get_parent()

func can_move() -> bool:
	return not is_moving and not is_talking

func move_to(target_position: Vector2) -> void:
	# 1. Define how fast you want the step to play
	# (You can use your 'speed' variable here to control the multiplier)
	var anim_speed_scale = speed  # e.g., if speed is 1.5, animation plays 1.5x faster
	
	chara_skin.set_animation_speed(anim_speed_scale)
	chara_skin.play_walk_animation()
	
	move_tween = create_tween()
	move_tween.connect("finished", _move_tween_done)
	
	# 2. KEY FIX: Calculate duration based on the ANIMATION, not the distance.
	# Formula: Time = Length / Speed
	# If the step is 0.8s long and speed is 1.0, it takes 0.8s to move.
	var step_duration = chara_skin.walk_length / anim_speed_scale
	
	# 3. Move the character over that exact duration
	move_tween.tween_property(self, "position", target_position, step_duration)
	
	is_moving = true

func _move_tween_done() -> void:
	move_tween.kill()
	chara_skin.toggle_walk_side()
	position = position.round()
	is_moving = false

func set_talking(talk_state: bool) -> void:
	is_talking = talk_state
