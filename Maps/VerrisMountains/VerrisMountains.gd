extends Node3D


@export var aether_count: Label
@export var marcy: Node3D
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
@export var health_bar: ProgressBar
var current_hostile_room = 99

@export var enemy_rooms: Array
@export var cleared_rooms: Array[int]

@export var room_enemies: Array[Node3D]

@export var brawler_ai: PackedScene

var wave_count = 0
var exit_room = 99
var shop_room = 99
