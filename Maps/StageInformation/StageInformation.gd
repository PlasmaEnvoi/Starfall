extends Resource

class_name StageData

@export_category("Generation Info")
@export var stage_name: String
@export var stage_size: Rect2
@export var seed_input: String

@export_range(1,3) var stage_difficulty : int

@export_category("Room Types")
@export var enemy_rooms: Array[PackedScene]
@export var utility_rooms: Array[PackedScene]
@export var exit_rooms: Array[PackedScene]

@export_category("Interactibles")
@export_subgroup("Obstacles")
@export var ground_hazards: Array[PackedScene]
@export var air_hazards: Array[PackedScene]
@export var wall_hazards: Array[PackedScene]
@export var ground_obstacles: Array[PackedScene]
@export var wall_obstacles: Array[PackedScene]
@export var ceiling_obstacles: Array[PackedScene]

@export_subgroup("Movement Decoration")
@export var horizontal_movement: Array[StageMovement]
@export var diagonal_movement: Array[StageMovement]
@export var vertical_movement: Array[StageMovement]

@export_category("Decorations")

@export_subgroup("Ground Decoration")
@export var gdeco_small: Array[StageDecoration]
@export var gdeco_medium: Array[StageDecoration]
@export var gdeco_large: Array[StageDecoration]

@export_subgroup("Air Decoration")
@export var air_deco: Array[StageDecoration]


@export_category("Enemies")
@export_subgroup("Difficulty 1")
@export var d1_enemies: Array[PackedScene]
@export var d1_minibosses: Array[PackedScene]

@export_subgroup("Difficulty 2")
@export var d2_enemies: Array[PackedScene]
@export var d2_minibosses: Array[PackedScene]

@export_subgroup("Difficulty 3")
@export var d3_enemies: Array[PackedScene]
@export var d3_minibosses: Array[PackedScene]

@export_subgroup("Bosses")
@export var bosses: Array[PackedScene]
