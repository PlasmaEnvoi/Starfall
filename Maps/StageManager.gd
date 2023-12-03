@tool

extends Node3D

@export var Cell: PackedScene
@export var blank_cell: PackedScene
@export var Map: PackedScene
@export var map: Node2D
@export var grid_size: float

@export var rooms: Node3D

@export var map_groups: Array 

var neighbours = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

@export var placeholder_rect: Rect2
var used_tiles
var tileMap 
var cells = [MapBlock]
var blank_blocks = []
var room_ids = [10]
signal finished_base

#func _process(delta):
#
#	if Input.is_action_just_pressed("ui_accept"):
#		if Engine.is_editor_hint():
#			generate_map(placeholder_rect)

func generate_map(map_rect: Rect2):
	#print("Map Rect: ",map_rect)
	map_groups.clear()
	if rooms.get_child_count() != 0:
		for room in rooms.get_children():
			room.queue_free()
	cells.clear()
	if not Map is PackedScene: return
	map.generate_level(map_rect)
	tileMap = map.get_tilemap()
	used_tiles = tileMap.get_used_cells(0)
	var full_map = []
	var length_count = 0
	var height_count = 0
	for x in map_rect.size.x:
		for y in map_rect.size.x:
			full_map.append(Vector2i(x,y))
	for tile in full_map:
		if used_tiles.find(tile) == -1:
			var blank = blank_cell.instantiate()
			rooms.add_child(blank)
#			blank.grid_size = grid_size
			blank.position = Vector3(tile.x * grid_size, tile.y * grid_size, 0)
			blank_blocks.append(blank)
	for tile in used_tiles:
		var cell = Cell.instantiate()
		rooms.add_child(cell)
		cell.display_id.mesh = cell.display_id.mesh.duplicate()
		cell.grid_size = grid_size
		cell.position = Vector3(tile.x * grid_size, tile.y * grid_size, 0)
		cell.cell_pos = tile 
		cells.append(cell)
		
#	print(used_tiles)
	for c in cells:
		c.update_faces(used_tiles)
		
	map_groups.append([]) #0 - Hall L/R
	map_groups.append([]) #1 - Hall U/D
	map_groups.append([]) #2 - Starting Fill Locations
	map_groups.append([]) #3 - All Rooms
	
	var starter_blocks = []
	for c in cells:
		if (map.layout.get_used_cells(0).find(c.cell_pos + Vector2i.UP)) == -1 && (map.layout.get_used_cells(0).find(c.cell_pos + Vector2i.DOWN)) == -1:
			map_groups[0].append(c.cell_pos)
		elif (map.layout.get_used_cells(0).find(c.cell_pos + Vector2i.LEFT)) == -1 && (map.layout.get_used_cells(0).find(c.cell_pos + Vector2i.RIGHT)) == -1:
			map_groups[1].append(c.cell_pos)
			
	for cell_type in map_groups:
		for new_cell in cell_type:
				for n in neighbours:
					var possible_block = new_cell + n
					if  map.layout.get_used_cells(0).find(possible_block) != -1:
						if map_groups[0].find(possible_block) == -1 &&  map_groups[1].find(possible_block) == -1:
							starter_blocks.append(possible_block)
#	print(map_groups[2])
	for h in starter_blocks:
#		get_cell(h).block.show()
		map_groups[2].append(h)
		map_groups[3].append(h)
		
	#Make Rooms
	for h in map_groups[3]:
		for n in neighbours:
			var possible_block = h + n
			if  map.layout.get_used_cells(0).find(possible_block) != -1:
				if map_groups[0].find(possible_block) == -1 &&  map_groups[1].find(possible_block) == -1 && map_groups[3].find(possible_block) == -1:
					map_groups[3].append(possible_block)
					
#	for h in map_groups[3]:
#		get_cell(h).block.show()
			
	for cell in map_groups[3]:
		get_cell(cell).update_id(3)
			
	for cell in map_groups[0]:
		get_cell(cell).update_id(0)
			
	for cell in map_groups[1]:
		get_cell(cell).update_id(1)
			
	for cell in map_groups[2]:
		get_cell(cell).update_id(2)
		
	
	var room_cells = []
	for cell in map_groups[2]:
		if room_ids.find(get_cell(cell).room_id) != -1:
			pass
		else:
#			room_cells.clear()
			get_cell(cell).update_id(room_ids.back())
			room_cells.append(cell)
			for new_cell in room_cells:
#				print(room_cells)
				for n in neighbours:
					var possible_block = new_cell + n
					if map.layout.get_used_cells(0).find(possible_block) != -1:
						if map_groups[0].find(possible_block) == -1 &&  map_groups[1].find(possible_block) == -1 && (room_cells.find(possible_block) == -1 || get_cell(possible_block).room_id != get_cell(new_cell).room_id):
#							print("AddingBlock")
							get_cell(possible_block).update_id(room_ids.back())
							room_cells.append(possible_block)
			room_ids.append(room_ids.back()+1)
	print(room_ids)
	finished_base.emit()
#You're so fucking sick just so you know
		
func get_cell(pos_check):
	var return_cell
	for c in cells:
		if c.cell_pos == pos_check:
			return_cell = c
	return return_cell
#Map group 0 is L/R Hallway
#Map Group 1 is U/D Hallway

func get_room_position(room_id: int):
	var room_position : Vector3
	var room_size = 0
	for cell in cells:
		if cell.room_id == room_id:
			room_size += 1
			room_position += cell.position
	return room_position/room_size
