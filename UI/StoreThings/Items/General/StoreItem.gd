extends Resource

class_name StoreItem

enum possible_types{
	MOVE,
	SPEED,
	ENDURANCE,
	STRENGTH
}

@export var cost_range: Vector2
@export var item_type: possible_types
@export var move_anim: String
@export var move_desc: String
