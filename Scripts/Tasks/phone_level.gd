extends CanvasLayer

# --- SIGNALS ---
signal task_completed
signal task_failed

# --- CONFIGURATION ---
@export var dialogue_resource: DialogueResource
@export var start_node: String = "start"
@export var max_time: float = 60.0

# --- NODES ---
@onready var phone_anchor: Control = $PhoneAnchor
@onready var phone_graphic: TextureRect = $PhoneAnchor/PhoneGraphic
@onready var stress_timer: ProgressBar = $TimerContainer/StressTimer
@onready var confidence_meter: ProgressBar = $PhoneAnchor/ConfidenceMeter
@onready var dialogue_label: RichTextLabel = $DialogueArea/VBoxContainer/DialogueLabel
@onready var responses_menu: VBoxContainer = $DialogueArea/VBoxContainer/ResponsesMenu
@onready var dialogue_area: PanelContainer = $DialogueArea

# --- STATE ---
var current_time: float
var is_active: bool = false
var temporary_game_state: Array = [] # Required by Dialogue Manager

func _ready() -> void:
	# 1. Initialize State
	visible = false
	current_time = max_time
	Global.confidence = 100.0
	
	# 2. Setup UI Values
	stress_timer.max_value = max_time
	stress_timer.value = max_time
	confidence_meter.max_value = 100.0
	confidence_meter.value = 100.0
	
	# 3. Hide dialogue box initially
	dialogue_area.modulate.a = 0

# Call this from Global to start the encounter
func start_encounter() -> void:
	print("DEBUG: start_encounter called!")
	
	Global.is_dialogue_active = true  # Locks player movement
	
	visible = true
	is_active = true
	
	# Check if resource exists
	if dialogue_resource == null:
		printerr("CRITICAL ERROR: No Dialogue Resource assigned!")
		return

	# FORCE the positions (Reset them first so we know where they are)
	# Assuming your Anchor is Bottom Right
	phone_anchor.position.y = get_viewport().get_visible_rect().size.y 
	var target_y = get_viewport().get_visible_rect().size.y - 400
	
	print("DEBUG: Animating Phone from ", phone_anchor.position.y, " to ", target_y)

	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(phone_anchor, "position:y", target_y, 0.6)
	
	# Fade in Text
	create_tween().tween_property(dialogue_area, "modulate:a", 1.0, 0.3)
	
	_next_line(start_node)

func _process(delta: float) -> void:
	if not is_active: return
	
	# --- 1. HANDLE TIMER ---
	current_time -= delta
	stress_timer.value = current_time
	
	# Visual Panic: Turn timer red if low
	if current_time < 10.0:
		stress_timer.modulate = Color(1, 0, 0)
	else:
		stress_timer.modulate = Color(1, 1, 1)

	if current_time <= 0:
		_fail_level("CONNECTION LOST")

	# --- 2. HANDLE CONFIDENCE ---
	# Smoothly animate the bar to match Global.confidence
	confidence_meter.value = lerp(confidence_meter.value, Global.confidence, delta * 5.0)
	
	# Check for sudden drops (Screen Shake logic)
	if Global.confidence < confidence_meter.value - 5:
		_apply_shake()
		
	if Global.confidence <= 0:
		_fail_level("SUSPICION THRESHOLD EXCEEDED")

# --- DIALOGUE LOGIC ---


# 1. Update this function to pass 'line' instead of 'line.responses'
func _next_line(next_id: String) -> void:
	print("DEBUG: Fetching line for node: ", next_id)
	
	var line = await DialogueManager.get_next_dialogue_line(dialogue_resource, next_id, temporary_game_state)
	
	if line == null:
		_complete_level()
		return
		
	dialogue_label.text = line.text
	
	# CHANGE IS HERE: We pass the WHOLE line object now
	_update_responses(line)

# 2. Update this function to accept the line object
func _update_responses(line: DialogueLine) -> void:
	# Clear old buttons
	for child in responses_menu.get_children():
		child.queue_free()
		
	# Check if we have specific choices
	if line.responses.size() > 0:
		for response in line.responses:
			var btn = Button.new()
			btn.text = response.text
			# Make it look distinct
			btn.add_theme_color_override("font_color", Color.CYAN) 
			btn.pressed.connect(func(): _next_line(response.next_id))
			responses_menu.add_child(btn)
			
	# If NO choices (just text), create a "Continue" button
	else:
		var btn = Button.new()
		btn.text = " [ Next ] "
		btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
		# Use the line's default next_id
		btn.pressed.connect(func(): _next_line(line.next_id))
		responses_menu.add_child(btn)
		
		# Optional: Auto-focus this button so Spacebar works
		btn.grab_focus()


func _on_response_selected(response) -> void:
	_next_line(response.next_id)

# --- ENDING STATES ---

func _complete_level() -> void:
	is_active = false
	print("Level Complete")
	Global.complete_task()
	
	Global.is_dialogue_active = false # Unlocks player movement
	
	_animate_exit()

func _fail_level(reason: String) -> void:
	is_active = false
	dialogue_label.text = "[color=red][b]FAILED: " + reason + "[/b][/color]"
	
	# Remove buttons
	for child in responses_menu.get_children():
		child.queue_free()
	
	# Wait a moment, then restart or game over
	await get_tree().create_timer(2.0).timeout
	
	# OPTION A: Reload Scene
	# get_tree().reload_current_scene()
	
	# OPTION B: Close phone (letting player try again later)
	_animate_exit()

func _animate_exit() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	
	# 1. Slide the phone down
	tween.tween_property(phone_anchor, "position:y", phone_anchor.position.y + 500, 0.5)
	
	# 2. Fade out the Dialogue Box (Targeting the Node, not 'visible')
	tween.parallel().tween_property(dialogue_area, "modulate:a", 0.0, 0.5)
	
	# 3. Fade out the Timer
	tween.parallel().tween_property(stress_timer, "modulate:a", 0.0, 0.5)
	
	await tween.finished
	queue_free()


# --- JUICE ---
func _apply_shake() -> void:
	var tween = create_tween()
	var original_pos = phone_anchor.position
	for i in range(5):
		var offset_pos = Vector2(randf_range(-5, 5), randf_range(-5, 5))
		tween.tween_property(phone_anchor, "position", original_pos + offset_pos, 0.05)
	tween.tween_property(phone_anchor, "position", original_pos, 0.05)
