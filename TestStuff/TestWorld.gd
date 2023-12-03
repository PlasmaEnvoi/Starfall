extends Node3D

@export var aether_count: Label
@export var marcy: CharacterBody3D
@export var map_gen: Node3D
@export var room_id_label: Label
@export var current_room: Node3D

@export var exit_scene: PackedScene
@export var exit_crystal: Node3D

@export var shop_scene: PackedScene
@export var shop_crystal: Node3D

@export var existing_rooms: Array[int]

@export var current_biome_info: StageData 
@export var spawn_room_cells: Array
var wave_count = 0
var exit_room = 99
var shop_room = 99
@export var health_bar: ProgressBar
var current_hostile_room = 99

@export var enemy_rooms: Array
@export var cleared_rooms: Array[int]


@export var room_enemies: Array[Node3D]

@export var brawler_ai: PackedScene
var map_active = false
var locked_objects = []

func _ready():
	map_active = false
	map_gen.finished_base.connect(populate_map)
	map_gen.generate_map(current_biome_info.stage_size)
	marcy.aether_changed.connect(update_aether_label)
	marcy.health_update.connect(update_health_bar)
	update_aether_label()
	update_health_bar()
	
func update_aether_label():
	aether_count.text = "Æther: " + str(marcy.aether)
	
func update_health_bar():
	print(marcy.health)
	print(marcy.max_health)
	health_bar.value = marcy.health
	health_bar.max_value = marcy.max_health
	
func populate_map():
#	print("Attempting Populate")
#Checking cells for cells with floors
	for cell in map_gen.map_groups[3]:
		var current_cell = map_gen.get_cell(cell)
		if current_cell.floor != null:
			var new_deco
			var spawn_scale = 1
			var spawn_count =  randi_range(10,20)
			var spawn_flip = -1
			while spawn_count > 0:
			#Small Spawn
				var current_floor_deco = current_biome_info.gdeco_small.pick_random()
				var deco_scene = current_floor_deco.deco_scene.instantiate()
				current_cell.floor_spawn.add_child(deco_scene)
				deco_scene.rotation_degrees.y += randi_range(current_floor_deco.min_rotation,current_floor_deco.max_rotation)
				deco_scene.position.x += randf_range(-8,8)
				deco_scene.position.z += randf_range(5,30) * (spawn_flip)
				spawn_flip *= -1
				deco_scene.global_scale (current_floor_deco.min_scale * randf_range(1 -current_floor_deco.scale_variation, 1 + current_floor_deco.scale_variation))
				
				spawn_count -= 1
				
			spawn_count = randi_range(3,6)
			#Medium Spawn
			while spawn_count > 0:
				var current_floor_deco = current_biome_info.gdeco_medium.pick_random()
				var deco_scene = current_floor_deco.deco_scene.instantiate()
				current_cell.floor_spawn.add_child(deco_scene)
				deco_scene.rotation_degrees.y += randi_range(current_floor_deco.min_rotation,current_floor_deco.max_rotation)
				deco_scene.position.x += randf_range(-7,7)
				deco_scene.position.z += randf_range(15,40) * (spawn_flip)
				spawn_flip *= -1
				deco_scene.global_scale (current_floor_deco.min_scale * randf_range(1 -current_floor_deco.scale_variation, 1 + current_floor_deco.scale_variation))
				
				spawn_count -= 1
			#Check size of ground area
			if (cell + Vector2i.LEFT) in map_gen.used_tiles ||  (cell + Vector2i.RIGHT) in map_gen.used_tiles:
#				print(cell, " ", cell + Vector2i.LEFT, " ", cell + Vector2i.RIGHT)
				if randf() <=.75:
					var current_floor_deco = current_biome_info.gdeco_large.pick_random()
					var deco_scene = current_floor_deco.deco_scene.instantiate()
					current_cell.floor_spawn.add_child(deco_scene)
					deco_scene.rotation_degrees.y += randi_range(current_floor_deco.min_rotation,current_floor_deco.max_rotation)
					deco_scene.global_scale (current_floor_deco.min_scale * randf_range(1 -current_floor_deco.scale_variation, 1 + current_floor_deco.scale_variation))
					deco_scene.position.x += randf_range(-4,4)
					deco_scene.position.z -= randf_range(10,30)
	#Check Room Height
	print("Room Ids",map_gen.room_ids)
	
	for room_cell in map_gen.map_groups[3]:
		var current_room_cell = map_gen.get_cell(room_cell)
#		print(current_room_cell)
		current_room_cell.player_entered_cell.connect(update_player_cell)
		
	#Check height to shaft halls
	for shaft_cell in map_gen.map_groups[1]:
		var height_check = 3
		var drop_cells = []
		var adjacent_cell = shaft_cell
		while adjacent_cell in map_gen.used_tiles && (4):
			if adjacent_cell in map_gen.map_groups[1] && adjacent_cell != shaft_cell:
				break
			else:
#				print("in")
				drop_cells.append(adjacent_cell)
				adjacent_cell += Vector2i.UP
		if drop_cells.back() == shaft_cell:
			pass
		else:
			var current_cell = map_gen.get_cell(drop_cells.back())
			var vert_mover = current_biome_info.vertical_movement.pick_random()
			var object = vert_mover.mover_scene.instantiate()
			locked_objects.append(object)
			object.room_id = current_cell.room_id
			current_cell.floor_spawn.add_child(object)
			object.rotation_degrees.y += randi_range(vert_mover.min_rotation,vert_mover.max_rotation)
			object.vert_severity = drop_cells.size()
			object.global_scale (vert_mover.min_scale * randf_range(1 -vert_mover.scale_variation, 1 + vert_mover.scale_variation))
#		print("Shaft Cell: ", shaft_cell)
#		print("Drop Cells: ", drop_cells)
	make_golden_path()

func make_golden_path():
	existing_rooms.clear()
	for cell in map_gen.cells:
		if existing_rooms.find(cell.room_id) == -1:
			existing_rooms.append(cell.room_id)
	existing_rooms.sort()
	
	var copy_rooms = existing_rooms.duplicate()
	copy_rooms.shuffle()
	
	var created_store = false
	var created_end = false
	spawn_marcy()
#Set ids of the exit and shop rooms so we don't spawn enemies in there
	
#Lets make sure that the biggest rooms can't get the shop or the exit
	var largest_room = [0,0]
	var second_largest_room = [0,0]
	print("New Rooms: ",copy_rooms)
	
	
	for room_id in copy_rooms:
		if room_id > 10:
			print(room_id, " Dist to Spawn:",map_gen.get_room_position(10).distance_to(map_gen.get_room_position(room_id)))
	
	for room_id in copy_rooms:
		if room_id > 10:
			var room_size = 0
			for cell in map_gen.cells:
				if cell.room_id == room_id:
					room_size += 1
			print("Room #", room_id, " - ", room_size)
			if room_size > largest_room[1]:
				largest_room[0] = room_id
				largest_room[1] = room_size
			elif room_size > second_largest_room[1]:
				second_largest_room[0] = room_id
				second_largest_room[1] = room_size
				
	print("Largest Room Size: ", largest_room)
	print("Second Largest Room Size: ", second_largest_room)
	
	for current_room_id in copy_rooms:
		var has_set_room_info = false
		if current_room_id > 10 && current_room_id != largest_room[0] && current_room_id != second_largest_room[0]:
			map_gen.cells.shuffle()
			for cell in map_gen.cells:
				if cell.floor != null && cell.room_id == current_room_id && (created_store == false || created_end == false):
					if created_end == false && has_set_room_info == false:
						created_end = true
						exit_room = current_room_id
						exit_crystal = exit_scene.instantiate()
						cell.floor_spawn.add_child(exit_crystal)
						await get_tree().process_frame
						exit_crystal.global_scale(Vector3(1.1,1.1,1.1))
						has_set_room_info = true
						
					elif created_store == false && has_set_room_info == false:
						created_store = true
						shop_room = current_room_id
						shop_crystal = shop_scene.instantiate()
						cell.floor_spawn.add_child(shop_crystal)
						await get_tree().process_frame
						shop_crystal.global_scale(Vector3(1.1,1.1,1.1))
						has_set_room_info = true
						
	for current_room_id in copy_rooms:
		if current_room_id !=  exit_room && current_room_id !=  shop_room && current_room_id!= 10:
			enemy_rooms.append([current_room_id, null])
		else:
			for obj in locked_objects:
				if obj.room_id == current_room_id:
					obj.unlock()
	map_active = true

func update_player_cell(id, cell_pos):
#	print(id, cell_pos)
	if  current_room == null || id != current_room.room_id:
		current_room = map_gen.get_cell(cell_pos)
		room_id_label.text = str(current_room.room_id)
		var found_enemy_room = false
		for room_id in enemy_rooms:
			#print(room_id, " ", id)
			var found_cleared_room = false
			if cleared_rooms.find(room_id[0]) != -1:
				found_cleared_room = true
			if room_id[0] == id && found_cleared_room == false && found_enemy_room == false:
				found_enemy_room = true
				current_hostile_room = id
				begin_hostile_room()
				wave_count = randi_range(0,2)
				#print("Wave Count ", wave_count)
		
func begin_hostile_room():
	#print("Beginning Hostile room!!")
	
	for cell in map_gen.cells:
		if cell.room_id == 0 || cell.room_id == 1:
			cell.set_room_lock(false)
			
	var enemy_count = randi_range(2,4)
	while enemy_count > 0:
		var new_enemy = current_biome_info.d1_enemies.pick_random()
		map_gen.cells.shuffle()
		for cell in map_gen.cells:
			if enemy_count <= 0 :
				break
			var spawned_enemy = brawler_ai.instantiate()
			spawned_enemy.unit_type = new_enemy
			spawned_enemy.death_info.connect(unit_death)
			if cell.room_id == current_hostile_room && cell.floor != null:
				cell.floor_spawn.add_child(spawned_enemy)
				spawned_enemy.aether = ((spawned_enemy.unit.aether_drop_mod + randi_range(0,10) * current_biome_info.stage_difficulty))
				spawned_enemy.position.x += randf_range(-4,4)
				spawned_enemy.add_to_group("Enemy")
				if randf() < .5:
					spawned_enemy._flip()
					
				room_enemies.append(spawned_enemy)
				#print("Avast ye!!")
				enemy_count -= 1

func unit_death(unit):
	marcy.update_aether(unit.aether)
	room_enemies.erase(unit)
	#print(room_enemies)
	if room_enemies.is_empty():
		if wave_count > 0:
			wave_count -= 1
			#print("Waves left: ", wave_count)
			begin_hostile_room()
		else:
			#print(current_room.room_id, " cleared!!")
			cleared_rooms.append(current_room.room_id)
			for cell in map_gen.cells:
				if cell.room_id == 0 || cell.room_id == 1:
					cell.set_room_lock(true)
			for obj in locked_objects:
				if obj.room_id == current_hostile_room:
					obj.unlock()
					
func spawn_marcy():
	var possible_cells = map_gen.cells.duplicate()
	possible_cells.shuffle()
	var rand_spawn_point = Vector3.ZERO
	var room_size = 0
	for cell in possible_cells:
		if cell.room_id == 10:
			if cell.floor != null:
				rand_spawn_point = cell.global_position + Vector3(0,2,0)
				break
	marcy.velocity = Vector3.ZERO
	marcy.global_position.x = rand_spawn_point.x
	marcy.global_position.y = rand_spawn_point.y
