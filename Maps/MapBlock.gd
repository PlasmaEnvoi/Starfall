@tool

extends Node3D
class_name MapBlock
@export var cell_pos: Vector2i
@export var ceiling: Node3D
@export var floor: Node3D
@export var left_wall: Node3D
@export var right_wall: Node3D
@export var player_block: CollisionShape3D

@export var floor_spawn: Marker3D
@export var ceiling_spawn: Marker3D
@export var lwall_spawn: Marker3D
@export var rwall_spawn: Marker3D

@export var detect_player: Area3D

@export var grid_size: int

@export var room_id: int = -1
@export var display_id: MeshInstance3D

signal player_entered_cell

func _ready():
	set_room_lock(true)
	
func set_room_lock(not_blocking):
	await get_tree().process_frame
	player_block.set_deferred("disabled", not_blocking)
	
func update_id(new_id: int):
	room_id = new_id
	display_id.mesh.text = str(new_id)

func update_faces(cell_list):
	if cell_list.has(cell_pos + Vector2i.UP):
		floor.queue_free()
		floor = null
		
	if cell_list.has(cell_pos + Vector2i.DOWN):
		ceiling.queue_free()
		ceiling = null
		
	if cell_list.has(cell_pos + Vector2i.LEFT):
		left_wall.queue_free()
		left_wall = null
		
	if cell_list.has(cell_pos + Vector2i.RIGHT):
		right_wall.queue_free()
		right_wall = null

func player_entered(body):
	if body.is_in_group("Player"):
		player_entered_cell.emit(room_id, cell_pos)

