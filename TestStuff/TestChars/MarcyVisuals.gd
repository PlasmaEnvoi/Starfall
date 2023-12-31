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
@export var dash_anim: String
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

@export_category("Attack Data")
@export_category("Timers")
var pause_timer
var invulflash: Timer
var flash_bool

signal hitframe
signal play_sound
signal start_invul

func _ready():
	pause_timer = Timer.new()
	pause_timer.one_shot = true
	pause_timer.process_mode = Node.PROCESS_MODE_ALWAYS 
	pause_timer.timeout.connect(pause_over)
	add_child(pause_timer)
	
	invulflash = Timer.new()
	invulflash.one_shot = false
	invulflash.wait_time = .1
	invulflash.timeout.connect(flashing_invul)
	add_child(invulflash)
	
	anims.animation_finished.connect(_end_anims)
	hitbox_a.area_entered.connect(detected_hit)
	animtree.active = true
	
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
#		anims.call_deferred("stop")
#	print(anim,  " - ", input)
	
#	print(anims.get_current_animation())
	match anim:
		"Idle":
			main_node.override_hit = false
			if anim_lock == false:
				main_node.can_cancel = true
				animtree.set("parameters/GroundAirBlend/blend_amount", 0)
				ground_combo_progression = 0
			
		"Brake":
			main_node.override_hit = false
			if anim_lock == false:
				animtree.set("parameters/GroundAirBlend/blend_amount", 0)
				animtree.set("parameters/GroundMove/blend_amount", 0)
				animtree.set("parameters/BrakeBlend/blend_amount", abs(main_node.velocity.x/main_node.walk_speed))
				
		"GroundMove":
			main_node.override_hit = false
			if anim_lock == false:
				animtree.set("parameters/GroundAirBlend/blend_amount", 0)
				animtree.set("parameters/GroundMove/blend_amount", abs(main_node.velocity.x/main_node.walk_speed))
#				print(abs(main_node.velocity.x/main_node.walk_speed))
		"Jump":
			main_node.override_hit = false
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
			main_node.override_hit = false
			if anims.get_current_animation() != (dash_anim):
				anim_lock = true
				animtree.active = false
				anims.play(dash_anim)
		"Recover":
			main_node.override_hit = false
			if anims.get_current_animation() != (recover_air):
				print("Attempting Recover")
				anim_lock = true
				invul_start(.5)
				animtree.active = false
				movement_impulse(main_node.input_dir if main_node.input_dir != Vector2.ZERO else Vector2(0,6), true, true)
				anims.play(recover_air)
		"Airmove":
			main_node.override_hit = false
			if anim_lock == false:
				animtree.set("parameters/GroundAirBlend/blend_amount", 1)
				if main_node.fast_fall == true: 
					animtree.set("parameters/JumpTree/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT)
				animtree.set("parameters/FallSwitch/blend_amount", -1 if main_node.fast_fall == true else 0)
			
		"Wallslide":
			main_node.override_hit = false
			if anim_lock == false:
				animtree.set("parameters/GroundAirBlend/blend_amount", 1)
				animtree.set("parameters/JumpTree/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
				animtree.set("parameters/FallSwitch/blend_amount", 1)
			
		"Land":
			main_node.override_hit = false
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
			print("Checking input: ",input)
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
		main_node.override_hit = false
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
	if anim_name == dash_anim:
		manage_anims("Airmove", "")
	if main_node.is_hurt == false:
		return_neutral()
	
func return_neutral():
	main_node.override_hit = false
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
	main_node.has_gravity = true
	main_node.has_friction = true
	main_node.can_cancel = false
	main_node.hit_enemies.clear()
	current_hitbox_data = info.duplicate()
	current_hitbox_data.move_owner = get_path()
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
	new_spark.rotation_degrees.y +=  ( 180 if main_node.facing_right == false else 0)
	
func detected_hit(target):
	main_node.can_jump = true if current_hitbox_data.jump_cancel == true else false
	main_node.can_cancel = true
	if current_hitbox_data.hits_once == true && main_node.hit_enemies.find(target) == -1:
		resolve_hit(target)
	elif current_hitbox_data.hits_once != true:
		resolve_hit(target)
		
func resolve_hit(target):
		main_node.hit_enemies.append(target)
		hit_pause([anims.get_current_animation(),anims.get_current_animation_position()]) 
		create_spark(basic_hitspark)
		if target.owner.is_in_group("Projectile") || target.is_in_group("Projectile"):
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
	
func override_hurt(active: bool, override_anim : String):
	main_node.override_hurt = active
	main_node.ov_hurt_anim = override_anim
	
func pause(pause_time : float):
#	print()
	get_tree().paused = true
	pause_timer.wait_time = pause_time
	pause_timer.start()
	
func pause_over():
	get_tree().paused = false
	
func invul_start(time : float):
	start_invul.emit(time)
	hurtbox.monitoring = false
	hurtbox.monitorable = false
	invulflash.start()
	
func invul_end():
	hurtbox.monitoring = true
	hurtbox.monitorable = true
	invulflash.stop()
	show()

func flashing_invul():
	show() if flash_bool == true else hide()
	flash_bool = !flash_bool
	
func vel_reset():
	main_node.has_gravity = true
	main_node.has_friction = true
