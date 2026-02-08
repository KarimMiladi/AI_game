class_name TaskObject
extends Pawn

# What is this item called in the Global inventory?
@export var item_id: String = "book"
@export var quantity: int = 1

# Does this item disappear when picked up?
@export var is_pickup: bool = true

@export var required_task_index: int = 0

func _ready() -> void:
	# No need to set CELL_TYPES anymore. 
	# Just ensure this object has a CollisionShape2D in the scene!
	pass

# Called by Player.gd -> _try_interact()
func trigger_event(_direction: Vector2i) -> void:
	
	if Global.current_task_index != required_task_index:
		print("I shouldn't do this yet.")
		# Optional: Add a "Not now" dialogue here
		return
	
	# 1. Add to Global Inventory
	Global.add_item(item_id, quantity)
	
	# 2. Feedback
	print("Picked up ", quantity, " ", item_id)
	
	# 3. Handle object cleanup
	if is_pickup:
		queue_free() # Physics engine handles removal automatically
	else:
		# If it's a switch or permanent object
		pass
