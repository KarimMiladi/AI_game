extends Character

# --- DIALOGUE SETUP ---
# Hardcoded path is risky if you move files, but we'll stick with it for now.
var dialogue_resource = ResourceLoader.load("res://Resources/Dialogues/tasks.dialogue", "", ResourceLoader.CACHE_MODE_IGNORE)
@export var dialogue_start: String = "start"
@export var balloon_scene: PackedScene

var player_in_range: bool = false
var can_interact: bool = true 

func _process(_delta: float) -> void:
	# DEBUG: Uncomment the line below if you think the Input isn't working
	# if Input.is_action_just_pressed("interact"): print("Interact pressed!")

	if player_in_range and Input.is_action_just_pressed("interact"):
		print("Input detected inside range!") # DEBUG PRINT
		
		if Global.is_dialogue_active:
			print("Blocked: Dialogue already active.")
			return
			
		if not can_interact:
			print("Blocked: Interaction Cooldown.")
			return
			
		run_dialogue()

func run_dialogue() -> void:
	print("Starting Dialogue...")
	Global.is_dialogue_active = true
	can_interact = false
	
	print("Balloon Scene: ", balloon_scene)
	print("Dialogue Resource: ", dialogue_resource)
	
	if balloon_scene and dialogue_resource:
		var balloon = balloon_scene.instantiate()
		get_tree().root.add_child(balloon)
		balloon.start(dialogue_resource, dialogue_start)
		
		await balloon.tree_exited
		print("Dialogue Finished.")
	else:
		printerr("ERROR: Missing Balloon Scene or Dialogue Resource!")
	
	# Cooldown
#	await get_tree().create_timer(0.5).timeout
	Global.is_dialogue_active = false
	can_interact = true
	print("NPC Ready again.")

# --- SIGNAL CONNECTIONS ---
func _on_area_2d_body_entered(body: Node2D) -> void:
	# Check if it's the player (assuming Player is CharacterBody2D)
	if body is CharacterBody2D and body != self:
		print("Player entered interaction range") # DEBUG PRINT
		player_in_range = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D and body != self:
		print("Player left interaction range") # DEBUG PRINT
		player_in_range = false
