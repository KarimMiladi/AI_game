extends Area2D

# 1. IDENTIFICATION
# You MUST set this in the Inspector for each book (e.g., "book_kitchen", "book_hall")
@export var unique_id: String = ""

# 2. SETTINGS
@export var item_name: String = "book"
@export var books_needed_to_finish: int = 3 

var player_inside: bool = false

func _ready() -> void:
	# PERMANENCE CHECK:
	# "Hey Global, did the player already pick me up in the past?"
	if unique_id != "" and Global.is_object_collected(unique_id):
		queue_free() # Delete myself immediately

func _process(_delta: float) -> void:
	# Check inputs, range, and if we are actually on the Book Task (Task 0)
	if player_inside and Input.is_action_just_pressed("interact") and Global.current_task_index == 0:
		collect_book()

func collect_book() -> void:
	# 1. Register as "Dead" so it never respawns
	if unique_id != "":
		Global.register_object_collected(unique_id)
	else:
		printerr("WARNING: This book has no Unique ID! It will respawn.")

	# 2. Add to Inventory (This counts UP, not down)
	Global.add_item(item_name, 1)
	
	# 3. Check for Task Completion
	# We check if we have collected enough books total
	var current_count = Global.inventory.get(item_name, 0)
	print("Books collected: ", current_count, " / ", books_needed_to_finish)
	
	if current_count >= books_needed_to_finish:
		print("All books found! Finishing Task 0.")
		Global.complete_task()
	
	# 4. Disappear
	queue_free()

# --- SIGNAL CONNECTIONS ---
func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_inside = true

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_inside = false
