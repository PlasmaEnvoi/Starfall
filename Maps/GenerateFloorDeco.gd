extends Node3D

@export var current_items: Array[Node3D]
var select_item

func _ready():
	print(select_item)
	select_item = current_items.pick_random()
	for item in current_items:
		if item != select_item:
			item.queue_free()
