class_name TaskObject
extends Pawn

# What is this item called in the Global inventory?
@export var item_id: String = "book"
@export var quantity: int = 1

# Does this item disappear when picked up? (True for books, False for a computer terminal)
@export var is_pickup: bool = true

@export var required_task_index: int = 0

# Optional: Sound or visual effect here
# @onready var audio = $AudioStreamPlayer2D

func _ready() -> void:
	# Crucial: Set type to ACTOR so the ActorGrid detects interaction
	type = CELL_TYPES.ACTOR

# This is called by ActorGrid when the player presses UI_ACCEPT facing this object
func trigger_event(_direction: Vector2i) -> void:
	
	if Global.current_task_index != required_task_index:
		print("I shouldn't do this yet.")
		# Optional: trigger a generic "Not now" dialogue balloon here
		return
	
	# 1. Add to Global Inventory
	Global.add_item(item_id, quantity)
	
	# 2. Feedback (Optional: You can trigger a small Dialogue balloon here too!)
	print("Picked up ", quantity, " ", item_id)
	
	# 3. Handle object cleanup
	if is_pickup:
		# Remove from the grid physically
		queue_free()
		# NOTE: You might need to manually free the cell in ActorGrid if your 
		# grid doesn't auto-update on child exit. 
		# If you see "ghost collision", we can add a cleanup line here.
	else:
		# If it's not a pickup (like a switch), maybe play an animation?
		pass
