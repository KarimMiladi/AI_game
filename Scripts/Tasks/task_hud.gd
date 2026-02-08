extends Control

@onready var label: Label = $Label

func _process(_delta):
	if Global.task_active and Global.current_task_index == 0:
		var count = Global.inventory.get("book", 0)
		label.text = "Books Recycled: " + str(count) + " / 3"
		label.visible = true
	else:
		label.visible = false
