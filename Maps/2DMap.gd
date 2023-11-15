@tool

extends Node2D

@export var layout: TileMap
@export var seed_input: String
@export var gen_seed: int


func get_tilemap():
	return layout
	
func check_seed():
	gen_seed = randi_range(100000,999999) if seed_input == "" else hash(seed_input)
	seed(gen_seed)
	
	
func generate_level(map_rect: Rect2):
	check_seed()
	layout.clear()
	var walker = Walker.new(Vector2(1,1), map_rect)
	var map = walker.walk(randi_range(50,60))
	walker.direction = Vector2.RIGHT
	walker.walk(5)
	walker.create_room(walker.position, Vector2(3,3))
	
	walker.queue_free()
	
	for location in map:
#		print(location)
		layout.set_cell(0,location, 0, Vector2.ZERO)
		
#	print(layout.get_used_cells(0))
	
