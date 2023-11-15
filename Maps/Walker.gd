extends Node

class_name Walker

const DIRECTIONS = [Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

var position = Vector2.ZERO
var direction = Vector2.RIGHT
var borders = Rect2()
var step_history = []

var spawn_distance = 4

var steps_since_turn = 0



func _init(starting_position, new_borders):
	assert(new_borders.has_point(starting_position))
	position = starting_position
	step_history.append(position)
	borders = new_borders
	create_room(position, Vector2(3,3))
	walk(8)

	
func walk(steps):
	for step in steps:
		if steps_since_turn >= 6:
			change_dir()
			
		if step():
			step_history.append(position)
		else:
			change_dir()
	
	return step_history
	
func step():
	var target_pos = position + direction
	if borders.has_point(target_pos):
		position = target_pos
		steps_since_turn += 1
		return true
	else:
		return false
		
func change_dir():
	create_room(position, Vector2(randi_range(4,5),randi_range(3,5)))
	steps_since_turn = 0
	var possible_directions = DIRECTIONS.duplicate()
	possible_directions.erase(direction)
	
	direction = possible_directions.pick_random()
	
	while borders.has_point(position + direction) == false:
		direction = possible_directions.pick_random()
		
func create_room(room_pos,size):
	var top_left_corner = (position - size/2).ceil()
	
	for y in size.y:
		for x in size.x:
			var new_step = top_left_corner + Vector2(x,y)
			if borders.has_point(new_step):
				step_history.append(new_step)
