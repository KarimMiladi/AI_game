class_name TaskZone
extends Pawn

@export_group("Requirements")
@export var required_item: String = "book"
@export var required_amount: int = 3

@export_group("Completion Settings")
# If assigned, this SCENE will pop up (The Minigame)
@export var minigame_scene: PackedScene 
# If true, interaction immediately finishes the task (Use for Books, disable for Minigames)
@export var instant_complete: bool = true

@export_group("Feedback")
@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "cables_interaction"

# Use the same balloon scene you used in NPC.gd
@export var balloon_scene: PackedScene 

func _ready() -> void:
	type = CELL_TYPES.ACTOR

func trigger_event(_direction: Vector2i) -> void:
	# 1. Check if conditions are met
	if Global.has_item(required_item, required_amount):
		print("Requirements Met!")
		
		# A. If we have a minigame, launch it!
		if minigame_scene:
			_launch_minigame()
		
		# B. If it's an instant task (like the Book Bin), finish it now
		elif instant_complete and Global.task_active:
			Global.complete_task()
			_play_dialogue("success") # Dialogue title for success
			
	else:
		print("Missing items! Need: ", required_item)
		_play_dialogue("failure") # Dialogue title for failure

func _launch_minigame() -> void:
	print("Launching Minigame...")
	Global.is_dialogue_active = true # Stop player movement
	
	var minigame = minigame_scene.instantiate()
	get_tree().root.add_child(minigame)
	
	# Wait for the minigame to close (The minigame script must emit 'tree_exited')
	await minigame.tree_exited
	
	Global.is_dialogue_active = false # Resume movement
	
	# Optional: Check if minigame was WON before completing task
	# For now, we assume playing it = winning it
	if Global.task_active:
		Global.complete_task()

func _play_dialogue(title: String):
	# This is the same logic as your NPC.gd
	if dialogue_resource and balloon_scene:
		var balloon = balloon_scene.instantiate()
		get_tree().root.add_child(balloon)
		balloon.start(dialogue_resource, title)
