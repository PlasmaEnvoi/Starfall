extends Node3D

class_name GruntVisuals

var is_left_arm_blade: bool = true
var is_right_arm_blade: bool = true
var has_wings: bool = true
@export var unit_node: Node3D
@export var arm_l: Node3D
@export var arm_r: Node3D
@export var blade_l: Node3D
@export var blade_r: Node3D
@export var wings: Node3D

@export_group("Attacks")
@export var l_attack_actions: Array[String]
@export var r_attack_actions: Array[String]
@export var wing_attack_actions: Array[String]
@export var did_combo: bool
var current_anim

func _ready():
	unit_node.hitbox_a.area_entered.connect(override_hit)
	unit_node.hit_completed.connect(combo)

func get_attack_anim():
	var attack_anim = ""
	var possible_anims = []
	
	if is_left_arm_blade == true:
		possible_anims.append_array(l_attack_actions)
		
	if is_right_arm_blade == true:
		possible_anims.append_array(r_attack_actions)
		
	if has_wings == true:
		if is_left_arm_blade == true:
			possible_anims.append("BugMen_Attack_Wings_L_JumpSlash")
		if is_right_arm_blade == true:
			possible_anims.append("BugMen_Attack_Wings_R_JumpSlash")
			
		possible_anims.append_array(wing_attack_actions)
	attack_anim = possible_anims.pick_random()
	
	return attack_anim

func randomize_unit():
	#Set random blades
	var rand_check = randf()
	if rand_check <.33:
		is_left_arm_blade = false
		is_right_arm_blade = true
		arm_r.queue_free()
		blade_l.queue_free()
	elif rand_check <.66:
		is_left_arm_blade = true
		is_right_arm_blade = false
		arm_l.queue_free()
		blade_r.queue_free()
	else:
		is_left_arm_blade = true
		is_right_arm_blade = true
		
	#Set Random wings
	if randf()<.80:
		has_wings = false
		wings.queue_free()

func override_hit(hit_data):
	pass
	
func combo(hit_info : Move):
	if did_combo == false:
		var can_combo = 0
		
		if has_wings == true:
			can_combo += 1
		if is_left_arm_blade == true && is_right_arm_blade == true:
			can_combo += 1
		if can_combo > 0:
			var next_move = combo_check()
			print("Attempting Combo: ", next_move)
			if randf() < .80:
				unit_node.movement_impulse(Vector2(8,0),true,true)
				did_combo = true
				unit_node.anims.play(next_move)
				
func combo_check():
	var attack_anim = ""
	var possible_anims = []
	var used_l = false
	var used_r = false
	print(current_anim)
	if l_attack_actions.find(current_anim) != -1:
		used_l = true
		if is_right_arm_blade == true:
			possible_anims.append_array(r_attack_actions)
		
	elif r_attack_actions.find(current_anim) != -1:
		used_r = true
		if is_left_arm_blade == true:
			possible_anims.append_array(l_attack_actions)
			
	if has_wings == true:
		if is_left_arm_blade == true && used_l == false:
			possible_anims.append("BugMen_Attack_Wings_L_JumpSlash")
		if is_right_arm_blade == true && used_r == false:
			possible_anims.append("BugMen_Attack_Wings_R_JumpSlash")
		possible_anims.append_array(wing_attack_actions)
		
	print(possible_anims)
	possible_anims.erase(unit_node.anims.get_current_animation())
	print(possible_anims)
	attack_anim = possible_anims.pick_random()
	
	return attack_anim
