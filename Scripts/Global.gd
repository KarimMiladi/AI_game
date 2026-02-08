extends Node

signal dialogue_toggled(is_active: bool)
signal inventory_updated # Optional: Update HUD when items change

# --- INVENTORY & STATE ---
var inventory: Dictionary = {}
var current_task_index: int = 0

var confidence: float = 100.0:
	set(value):
		confidence = clamp(value, 0, 100)

var is_dialogue_active: bool = false:
	set(value):
		is_dialogue_active = value
		dialogue_toggled.emit(is_dialogue_active)

var task_active: bool = false:
	set(value):
		task_active = value
		print("DEBUG: Task Active changed to: ", task_active)

# --- 1. NEW INVENTORY FUNCTIONS (Required for TaskObject) ---
func add_item(item_id: String, amount: int = 1) -> void:
	if inventory.has(item_id):
		inventory[item_id] += amount
	else:
		inventory[item_id] = amount
	print("Added ", amount, " ", item_id, ". Total: ", inventory[item_id])
	inventory_updated.emit()

func has_item(item_id: String, amount: int = 1) -> bool:
	return inventory.get(item_id, 0) >= amount

func remove_item(item_id: String, amount: int = 1) -> void:
	if inventory.has(item_id):
		inventory[item_id] -= amount
		if inventory[item_id] <= 0:
			inventory.erase(item_id)
		inventory_updated.emit()

# --- TASK MANAGEMENT ---
func start_task():
	task_active = true
	
	match current_task_index:
		0:
			print("Starting Task 0: Books")
		1:
			print("Starting Task 1: Phone Call")
			_start_phone_delay()
		2:
			print("Starting Task 2: Fix Wires")
			# No special cutscene, just gameplay
			pass

func complete_task():
	task_active = false
	current_task_index += 1
	print("Task Completed. New Index: ", current_task_index)
	
	# Optional: Automatically start the next task?
	# start_task() 

func _start_phone_delay():
	print("Phone will ring in 1 second...")
	await get_tree().create_timer(1.0).timeout
	
	var scene_resource = load("res://Scenes/Tasks/phone_level.tscn")
	if not scene_resource:
		printerr("ERROR: Could not find PhoneLevel.tscn!")
		return
		
	var phone_scene = scene_resource.instantiate()
	
	# Ensure dialogue resource is loaded
	var dialogue_res = load("res://Resources/Dialogues/phone_call.dialogue")
	if dialogue_res:
		phone_scene.dialogue_resource = dialogue_res
	
	get_tree().root.add_child(phone_scene)
	phone_scene.start_encounter()


# A permanent list of object IDs that have been picked up
var collected_objects_registry: Array = []

func register_object_collected(id: String) -> void:
	if id != "" and not id in collected_objects_registry:
		collected_objects_registry.append(id)

func is_object_collected(id: String) -> bool:
	return id in collected_objects_registry
