class_name TaskZone
extends Pawn

@export_group("Requirements")
@export var required_item: String = "book"
@export var required_amount: int = 3

@export_group("Completion Settings")
@export var minigame_scene: PackedScene 
@export var instant_complete: bool = true

@export_group("Feedback")
@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "cables_interaction"
@export var balloon_scene: PackedScene 

func _ready() -> void:
	pass # Physics system handles position automatically

func trigger_event(_direction: Vector2i) -> void:
	# 1. Check if conditions are met
	if Global.has_item(required_item, required_amount):
		print("Requirements Met!")
		
		# A. Launch Minigame
		if minigame_scene:
			_launch_minigame()
		
		# B. Instant Complete
		elif instant_complete and Global.task_active:
			Global.complete_task()
			_play_dialogue("success") 
			
	else:
		print("Missing items! Need: ", required_item)
		_play_dialogue("failure") 

func _launch_minigame() -> void:
	print("Launching Minigame...")
	Global.is_dialogue_active = true # This stops the Player.gd _process loop
	
	var minigame = minigame_scene.instantiate()
	get_tree().root.add_child(minigame)
	
	await minigame.tree_exited
	
	Global.is_dialogue_active = false # Resumes movement
	
	if Global.task_active:
		Global.complete_task()

func _play_dialogue(title: String):
	if dialogue_resource and balloon_scene:
		var balloon = balloon_scene.instantiate()
		get_tree().root.add_child(balloon)
		balloon.start(dialogue_resource, title)
