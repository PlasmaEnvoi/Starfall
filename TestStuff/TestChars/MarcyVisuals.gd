extends Node3D

class_name MarcyForm

@export_group("Nodes")
@export var anims: AnimationPlayer
@export var anim_lock: bool = false
@export var animtree: AnimationTree
@export var main_node: Node3D
@export var unit_visuals: Node3D
@export var hurtbox: Area3D
@export var hitbox_a: Area3D
@export var hitbox_b: Area3D
@export var hitbox_c: Area3D
@export var current_hitbox_data: Move
@export var charge_effect: Node3D
@export var last_charge: float

@export_group("Info")

@export_group("Effects")
@export var unit_fx: PackedScene
@export var basic_hitspark: PackedScene
@export_color_no_alpha var test

@export_group("Form Anims")
@export var idle: String
@export var walk: String
@export var run: String
@export var hyper_run: String
@export var jump: String
@export var fall: String
@export var fast_fall: String
@export var land: String
@export var brake: String

@export_group("Form Hurts")
@export var hurt_light: String
@export var hurt_hard: String
@export var hurt_fall: String
@export var hurt_spike: String
@export var hurt_down: String
@export var hurt_bounce: String
@export var recover_air: String
@export var fall_anim: String

@export_group("Attack Vars")
@export var ground_combo_progression: int = 0
@export var air_combo_progression: int = 0

@export_group("Grounded Neutral Combo")
@export var ground_nl1: String
@export var ground_nl2: String
@export var ground_nl3: String

@export_group("Directional Moves")
@export var ground_dl: String
@export var ground_fl: String
@export var ground_ul: String

@export_group("Air Lights")
@export var air_nl: String
@export var air_fl: String
@export var air_dl: String
@export var air_ul: String

@export_group("Ground Specials")
@export var n_sp: String
@export var d_sp: String
@export var f_sp: String
@export var u_sp: String

@export_group("AttackFX")
@export var slash: Node3D


signal hitframe
signal play_sound

func _ready():
	anims.animation_finished.connect(_end_anims)
	hitbox_a.area_entered.connect(detected_hit)
	
func _process(delta):
	if main_node.charge >= 33:
		charge_effect.start_charge(main_node.charge)
	elif main_node.charge >= 66:
		charge_effect.start_charge(main_node.charge)
	else:
		charge_effect.stop_charge()
func manage_anims(anim, input):
	if anim_lock == false:
		anims.stop()
		
#	print(anim,  " - ", input)
	
#	print(anims.get_current_animation())
	match anim:
		"Idle":
			if anim_lock == false:
				main_node.can_cancel = true
				animtree.set("parameters/GroundAirBlend/blend_amount", 0)
				ground_combo_progression = 0
			
		"Brake":
			if anim_lock == false:
				animtree.set("parameters/GroundAirBlend/blend_amount", 0)
				animtree.set("parameters/GroundMove/blend_amount", 0)
				animtree.set("parameters/BrakeBlend/blend_amount", abs(main_node.velocity.x/main_node.walk_speed))
				
		"GroundMove":
			if anim_lock == false:
				animtree.set("parameters/GroundAirBlend/blend_amount", 0)
				animtree.set("parameters/GroundMove/blend_amount", abs(main_node.velocity.x/main_node.walk_speed))
		"Jump":
			if anim_lock == false:
				pass
			else: 
				return_neutral()
				_reset_anim()
			animtree.set("parameters/GroundAirBlend/blend_amount", 1)
			animtree.set("parameters/FallSwitch/blend_amount", -1 if main_node.fast_fall == true else 0)
			animtree.set("parameters/JumpTree/active", true)
			animtree.set("parameters/JumpType/blend_amount", clamp(main_node.velocity.x,0,0))
			animtree.set("parameters/JumpTree/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		"Dash":
			if anims.get_current_animation() != ("Marcy_Spear_Dash"):
				anim_lock = true
				animtree.active = false
				anims.play("Marcy_Spear_Dash")
			
		"Airmove":
			if anim_lock == false:
				animtree.set("parameters/GroundAirBlend/blend_amount", 1)
				if main_node.fast_fall == true: 
					animtree.set("parameters/JumpTree/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT)
				animtree.set("parameters/FallSwitch/blend_amount", -1 if main_node.fast_fall == true else 0)
			
		"Wallslide":
			if anim_lock == false:
				animtree.set("parameters/GroundAirBlend/blend_amount", 1)
				animtree.set("parameters/JumpTree/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
				animtree.set("parameters/FallSwitch/blend_amount", 1)
			
		"Land":
			if anim_lock == false:
				animtree.set("parameters/GroundAirBlend/blend_amount", 1)
				animtree.set("parameters/FallSwitch/blend_amount", 0 if main_node.fast_fall == true else 1)
			else: 
				return_neutral()
				_reset_anim()
	
		"Light":
#			print("========================================")
#			print("Emitted: ", anim)
#			print("Current Input:", input)
#			print("Animlock: ", anim_lock)
			manage_light_combo(input)
		"Heavy":
			var current_move
			if input == "fwd":
				current_move = f_sp
			elif input == "down":
				current_move = d_sp
			elif input == "up":
				current_move = u_sp
			elif input == "":
				current_move = n_sp
			manage_heavy(current_move)
			
	if input == "Hurt" && anims.get_current_animation() != anim:
		animtree.active = false
		anims.play(anim)

		
func manage_heavy(current_move):
	print(current_move)
	main_node.can_jump = false
	if main_node.is_on_floor() == true && main_node.can_cancel == true:
		main_node.velocity.x = 0
		anim_lock = true
		animtree.active = false
#			print("Combo Progression: ", ground_combo_progression)
		if anims.get_current_animation() != (current_move) && current_move != null:
#			print(current_move)
			anims.play(current_move)
			
	elif main_node.is_on_floor() == false && main_node.can_cancel == true:
		anim_lock = true
		animtree.active = false
#		print("Check input: ", input)
#		print("Attempt Move: ", current_move)
		if anims.get_current_animation() != (current_move):
			anims.play(current_move)
		
func manage_light_combo(input):
	main_node.can_jump = false
	var current_move
	if main_node.is_on_floor() == true && main_node.can_cancel == true:
		main_node.velocity.x = 0
		anim_lock = true
		animtree.active = false
		if input == "fwd":
			current_move = ground_fl
		elif input == "down":
			current_move = ground_dl
		elif input == "up":
			current_move = ground_ul
		elif input == "":
#			print("Combo Progression: ", ground_combo_progression)
			if anims.get_current_animation() != (ground_nl1) && ground_combo_progression == 0 && main_node.can_cancel == true:
				current_move = ground_nl1
			elif anims.get_current_animation() != (ground_nl2) && ground_combo_progression == 1 && main_node.can_cancel == true:
				current_move = ground_nl2
			elif anims.get_current_animation() != (ground_nl3) && ground_combo_progression == 2 && main_node.can_cancel == true:
					current_move = ground_nl3 
			ground_combo_progression += 1
		if anims.get_current_animation() != (current_move) && current_move != null:
#			print(current_move)
			anims.play(current_move)
			
	elif main_node.is_on_floor() == false && main_node.can_cancel == true:
		anim_lock = true
		animtree.active = false
#		print("Check input: ", input)
		if input == "fwd":
			current_move = air_fl
		elif input == "down":
			current_move = air_dl
		elif input == "up":
			current_move = air_ul
		elif input == "":
			current_move = air_nl
#		print("Attempt Move: ", current_move)
		if anims.get_current_animation() != (current_move):
			anims.play(current_move)
		

func emit_hit_frame():
	hitframe.emit()

func _reset_anim():
	if main_node.is_on_floor() == true:
		manage_anims("Idle", "")
	else: 
		manage_anims("Fall", "")
		

func cancel_switch(input_switch):
	main_node.can_flip = input_switch
	main_node.ctrl = input_switch
	main_node.can_cancel = input_switch

func _end_anims(anim_name):
#	print(anim_name)
	if main_node.is_hurt == false:
		return_neutral()
	
func return_neutral():
	hitbox_a.monitoring = false
	hitbox_b.monitoring = false
	hitbox_c.monitoring = false
	main_node.has_hit = false
	slash.hide()
	main_node.can_jump = true
	main_node.can_flip = true
	main_node.ctrl = true
	main_node.has_friction = true
	main_node.has_gravity = true
	main_node.can_cancel = true
	anim_lock = false
	animtree.active = true
	_reset_anim()

func movement_impulse(movement: Vector2, has_friction: bool, has_gravity: bool):
	if main_node.facing_right == false:
		movement.x *= -1
	main_node.impulse(movement.x, movement.y)
	main_node.has_gravity = has_gravity
	main_node.has_friction = has_friction
	

func establish_hitbox_info(info: Move):
	main_node.can_cancel = false
	main_node.has_hit = false
	current_hitbox_data = info.duplicate()
	current_hitbox_data.move_owner = self
	if main_node.facing_right == false:
		current_hitbox_data.ground_vel.x *= -1
		current_hitbox_data.air_vel.x *= -1
		current_hitbox_data.down_vel.x *= -1
		current_hitbox_data.hurt_vel.x *= -1
	
func create_spark(basic_hitspark):
	var new_spark = basic_hitspark.instantiate()
	get_tree().root.add_child(new_spark)
	new_spark.global_position.x = global_position.x + current_hitbox_data.spark_pos.x/100.0 * ( -1 if main_node.facing_right == false else 1)
	new_spark.global_position.y = global_position.y + current_hitbox_data.spark_pos.y/100.0
	new_spark.rotation_degrees.x = current_hitbox_data.spark_rot
	
func detected_hit(target):
	main_node.can_jump = true if current_hitbox_data.jump_cancel == true else false
	main_node.can_cancel = true
	if current_hitbox_data.hits_once == true && main_node.has_hit == false:
		resolve_hit(target)
	elif current_hitbox_data.hits_once != true:
		resolve_hit(target)
		
func resolve_hit(target):
		main_node.has_hit = true
		hit_pause([anims.get_current_animation(),anims.get_current_animation_position()]) 
		if target.is_in_group("Projectile"):
			pass
		else:
			target.owner.main_node.manage_hurt(current_hitbox_data)
	
func hit_pause(current_anim_data):
	anims.pause()
	main_node.store_vel(true)
	main_node.in_hitpause = true
	await get_tree().create_timer(current_hitbox_data.aggrressor_hitpause/50.0).timeout
	main_node.in_hitpause = false
	main_node.store_vel(false)
	anims.play()
	current_hitbox_data
	
func emit_sound(sound, strength):
	play_sound.emit(sound, strength)

func create_projectile(projectile_data: ProjectileData):
	var rotate_proj = 1
	if main_node.facing_right == false:
		rotate_proj = -1
	var proj = projectile_data.projectile_scene.instantiate()
	proj.projectile_contact.connect(proj_hit)
	if projectile_data.takes_charge == true:
		projectile_data.charge = last_charge
	proj.hit_list = projectile_data.hit_list
	proj.proj_owner = main_node
	proj.facing_right = main_node.facing_right
	proj.establish_data(projectile_data)
	get_tree().root.add_child(proj)
	
	if rotate_proj == -1:
		proj.rotation_degrees.y -= 180
		
	proj.global_position = global_position + projectile_data.offset_pos
	
func proj_hit():
	pass
