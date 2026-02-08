class_name Character
extends Pawn

@export var speed: float = 1.5
@onready var chara_skin: Sprite2D = $Skin

var move_tween: Tween
var is_moving: bool = false
var is_talking: bool = false

func can_move() -> bool:
	return not is_moving and not is_talking

func move_to(target_position: Vector2) -> void:
	is_moving = true
	
	var anim_speed_scale = speed
	chara_skin.set_animation_speed(anim_speed_scale)
	chara_skin.play_walk_animation()
	
	move_tween = create_tween()
	move_tween.connect("finished", _move_tween_done)
	
	# Calculate duration
	var step_duration = chara_skin.walk_length / anim_speed_scale
	
	# Move!
	move_tween.tween_property(self, "position", target_position, step_duration)

func _move_tween_done() -> void:
	if move_tween: move_tween.kill()
	chara_skin.toggle_walk_side()
	# Ensure perfect pixel snap at end of movement
	position = position.snapped(Vector2(1,1)) 
	is_moving = false

func set_talking(talk_state: bool) -> void:
	is_talking = talk_state
