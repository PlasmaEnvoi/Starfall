extends Node3D

@export var unit_node: Node3D

@export_group("Projectiles")
@export var boulder: PackedScene

@export_group("Attacks")
@export var ranged_attack_actions: Array[String]
@export var attack_actions: Array[String]
@export var did_combo: bool
@export var has_rock: bool
var current_anim

func _ready():
	unit_node.hitbox_a.area_entered.connect(override_hit)
	unit_node.hit_completed.connect(combo)

func get_attack_anim():
	var attack_anim = ""
	var possible_anims = []
	
	possible_anims = attack_actions.duplicate()
	attack_anim = possible_anims.pick_random()
	return attack_anim

func randomize_unit():
	pass

func override_hit(hit_data):
	pass
	
func combo(hit_info : Move):
	pass
#	if did_combo == false:
#		var next_move = combo_check()
#		print("Attempting Combo: ", next_move)
#		if randf() < .80:
#			unit_node.movement_impulse(Vector2(8,0),true,true)
#			did_combo = true
#			unit_node.anims.play(next_move)
				
func combo_check():
	var attack_anim = ""
	var possible_anims = []
	return attack_anim
	

func create_projectile(projectile_data: ProjectileData):
	var rotate_proj = 1
	if unit_node.main_node.facing_right == false:
		rotate_proj = -1
	var proj = projectile_data.projectile_scene.instantiate()
	proj.projectile_contact.connect(proj_hit)
	proj.hit_list = projectile_data.hit_list
	proj.proj_owner = unit_node.main_node
	proj.facing_right = unit_node.main_node.facing_right
	proj.establish_data(projectile_data)
	get_tree().root.add_child(proj)
	
	if rotate_proj == -1:
		proj.rotation_degrees.y -= 180
		
	proj.global_position = global_position + projectile_data.offset_pos
	
func proj_hit():
	pass
	
