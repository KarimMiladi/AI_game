extends Sprite2D

@onready var animation_tree: AnimationTree = $AnimationTree
# Get the playback object immediately so we can use it later
@onready var state_machine = animation_tree["parameters/StateMachine/playback"]

func set_animation_speed(value: float) -> void:
	animation_tree.set("parameters/TimeScale/scale", value)

func set_animation_direction(input_direction: Vector2) -> void:
	# Set the Blend Position for all states so transitions are smooth
	animation_tree.set("parameters/StateMachine/Idle/blend_position", input_direction)
	animation_tree.set("parameters/StateMachine/Walk0/blend_position", input_direction)
	# If you have Walk1, set it too, just in case
	animation_tree.set("parameters/StateMachine/Walk1/blend_position", input_direction)

func set_moving(is_moving: bool) -> void:
	if is_moving:
		# only travel to Walk if we aren't already there
		if state_machine.get_current_node() != "Walk0":
			state_machine.travel("Walk0")
	else:
		# only travel to Idle if we aren't already there
		if state_machine.get_current_node() != "Idle":
			state_machine.travel("Idle")
