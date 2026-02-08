extends Character

# Adjustable Movement Speed (Pixels per second)
const MOVE_SPEED = 90.0 
const INTERACT_DIST = 12.0 # How far forward to check for items

const MOVEMENTS: Dictionary = {
	'ui_up': Vector2i.UP,
	'ui_left': Vector2i.LEFT,
	'ui_right': Vector2i.RIGHT,
	'ui_down': Vector2i.DOWN 
}

var input_history: Array[String] = []
var cur_direction: Vector2i = Vector2i.DOWN

func _ready():
	super._ready()
	if Global.has_signal("dialogue_toggled"):
		Global.dialogue_toggled.connect(set_talking)

# We use _physics_process for real collision movement
func _physics_process(_delta) -> void:
	if Global.is_dialogue_active:
		return

	# 1. INPUT HANDLING
	input_priority()
	
	if Input.is_action_just_pressed("ui_accept"):
		_try_interact()

	# 2. MOVEMENT
	var input_dir: Vector2i = set_direction()
	
	if input_dir != Vector2i.ZERO:
		cur_direction = input_dir
		
		# Update Direction
		chara_skin.set_animation_direction(input_dir)
		
		# Tell Skin we are moving (It handles the "don't restart" check internally now)
		chara_skin.set_moving(true)
		
		velocity = Vector2(input_dir) * MOVE_SPEED
	else:
		# Tell Skin to stop
		chara_skin.set_moving(false)
		velocity = Vector2.ZERO

	# 3. APPLY PHYSICS
	move_and_slide()


func _try_interact():
	# LOGIC: Create a small 'sensor' circle just in front of the player.
	# offset: We multiply direction by INTERACT_DIST (12px)
	# This places the check center just outside the player's body.
	var check_pos = global_position + (Vector2(cur_direction) * INTERACT_DIST)
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	
	# Use a small circle (radius 6) to act as the "Hand"
	var selection_shape = CircleShape2D.new()
	selection_shape.radius = 6.0
	
	query.shape = selection_shape
	query.transform = Transform2D(0, check_pos)
	query.collide_with_areas = true 
	query.collide_with_bodies = true
	
	# Debug: Print where we are checking
	# print("Checking interaction at: ", check_pos)

	var results = space_state.intersect_shape(query)
	
	for result in results:
		var collider = result.collider
		
		if collider == self:
			continue
			
		if collider.has_method("trigger_event"):
			collider.trigger_event(cur_direction)
			return # Stop after finding the first item

# --- Input Handling (Kept exactly as you had it) ---
func input_priority() -> void:
	for direction in MOVEMENTS.keys():
		if Input.is_action_just_released(direction):
			var index: int = input_history.find(direction)
			if index != -1: input_history.remove_at(index)
		if Input.is_action_just_pressed(direction):
			input_history.append(direction)

func set_direction() -> Vector2i:
	var direction: Vector2i = Vector2i()
	if input_history.size():
		for i in input_history:
			direction += MOVEMENTS[i]
		match(input_history.back()):
			'ui_right', 'ui_left': if direction.x != 0: direction.y = 0
			'ui_up', 'ui_down': if direction.y != 0: direction.x = 0
	return direction
