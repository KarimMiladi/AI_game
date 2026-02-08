class_name Pawn
extends CharacterBody2D

# We don't need the CELL_TYPES enum anymore.
# We rely on Godot's "Groups" or simply checking if a script has a function.

func _ready() -> void:
	# Ensure all pawns snap to the grid on start
	position = position.snapped(Vector2(16, 16)) # Change 16 to your TILE_SIZE

# All pawns can be interacted with. By default, it does nothing.
func trigger_event(_direction: Vector2i) -> void:
	pass
