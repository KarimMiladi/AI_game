extends Character

# --- FIX 1: Use the correct Enum, not the number 2 ---
var dialogue_resource = ResourceLoader.load("res://Resources/Dialogues/tasks.dialogue", "", ResourceLoader.CACHE_MODE_IGNORE)

@export var dialogue_start: String = "start"

# Make sure you drag your "scary_balloon.tscn" here in the Inspector!
@export var balloon_scene: PackedScene

var curr_balloon = null
var can_interact = true 

func trigger_event(direction: Vector2i) -> void:
	# 1. THE GUARD
	if is_instance_valid(curr_balloon) or not can_interact:
		return

	if not is_moving:
		Global.is_dialogue_active = true;
		
		chara_skin.set_animation_direction(-direction)
		
		var balloon = balloon_scene.instantiate()
		get_tree().root.add_child(balloon)
		balloon.start(dialogue_resource, dialogue_start)
		
		curr_balloon = balloon
		
		# 2. WAIT FOR CLOSE
		await balloon.tree_exited
		curr_balloon = null
		
		# --- FIX 2: Safety Check ---
		# If the NPC isn't in the tree anymore (e.g. scene change), stop here to prevent the crash.
		if not is_inside_tree():
			return

		# 3. START COOLDOWN
		can_interact = false
		
		Global.is_dialogue_active = false
		
		# Now it is safe to call get_tree() because we checked is_inside_tree() above
		await get_tree().create_timer(1.0).timeout
		
		# Unlock interaction
		can_interact = true
