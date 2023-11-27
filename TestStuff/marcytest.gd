extends CharacterBody3D

@export var marcy_type: PackedScene
@export var char_visuals: MarcyForm
@export var l_wall_sensor: RayCast3D
@export var r_wall_sensor: RayCast3D
@export var floor_sensor: RayCast3D
@export var hurt_manager: Node3D

@export_group("Info")
@export var health: int = 100
@export var max_health: int = 100
@export var aether = 0

@export_group("Interacting Stuff")
@export var shop: Control
@export var dialogue: Control
var interacting = false

@export_group("MovementStats")
@export var walk_speed = 6.0
@export var acceleration = 25
@export var friction = 30
@export var drift_speed = 8.0
@export var air_friction = 7
@export var jump_speed = 14.5
@export var dash_speed = 12.5
@export var dash_length: float = 1.3
@export var max_air_actions = 2
@export var air_actions = 2
@export var max_air_jumps = 1
@export var air_jumps = 1
@export var wj_height = 14
@export var gravity = 30
@export var gravity_modifier = 1
var can_jump = true
var fast_fall = false
var land = true
var facing_right = true
var ctrl = true
var can_cancel = true
var can_flip = true
var wallslide = false
var current_wj_count = 1
var input_dir
var direction


var in_hitpause: bool = false
var is_hurt = false
var movement_paused: bool = false
var has_friction: bool = true
var has_gravity: bool = true
var init_pos : Vector3

var stored_vel: Vector3
var has_hit: bool
var hit_enemies: Array

var jump_buffer: float
var n_light_buffer: float
var f_light_buffer: float
var d_light_buffer: float
var u_light_buffer: float
var n_special_release_buffer: float
var f_special_buffer: float
var u_special_buffer: float
var d_special_buffer: float
var l_buffer: float
var r_buffer: float
var d_buffer: float
var u_buffer: float
var dash_buffer: float
var buffer_time: float = .15
var attacks_active = true
var lock_input = false

@export var charge: float = 0

@export var input_buffer: Timer
@export var unit: Node3D
@export var anims: AnimationPlayer
var current_interact

@export_group("Stats")
@export var strength: int = 1
@export var agility: int = 1
@export var endurance: int = 1

@export_group("Audio Stuff")
@export var audio_player: AudioStreamPlayer3D

@export_group("Hit Stuff")
@export var armored = false

@export_group("Override Checks")
@export var override_landing: bool
@export var override_hit: bool
@export var override_hurt: bool
@export var ov_landing_anim: String
@export var ov_hit_anim: String
@export var ov_hurt_anim: String

signal grounded(bool)
signal just_jumped
signal play_anims
signal aether_changed
signal health_update

func _ready():
	override_landing = false
	override_hit = false
	override_hurt = false
	shop.player = self
	shop.stock_store(shop.stock)
	dialogue.dialogue_over.connect(end_dialogue)
	hurt_manager.hurt_time_end.connect(end_hitstun)
	hurt_manager.update_anim.connect(anim_manager)
	
	hurt_manager.main_node = self
	hurt_manager.l_ray = l_wall_sensor
	hurt_manager.r_ray = r_wall_sensor
	
	grounded.connect(landing)
	
	char_visuals = marcy_type.instantiate()
	play_anims.connect(char_visuals.manage_anims)
	char_visuals.main_node = self
	add_child(char_visuals)
	char_visuals.global_rotation.y += deg_to_rad(90)
	char_visuals.play_sound.connect(audio_player.play_sound)
	anims = char_visuals.anims
	unit = char_visuals
	init_pos = char_visuals.position
	update_aether(0)
	
	health = max_health
	
func landing(land_check):
	air_actions = max_air_actions
	air_jumps = max_air_jumps
	land = true
	fast_fall = false
	gravity_modifier = 1
	wallslide = false
	current_wj_count = 1
#	print("landcheck")
	if is_hurt == false:
		play_anims.emit("Land", "")
	else:
		anim_manager("HurtDown")
	if override_landing == true:
		anims.play(ov_landing_anim)
		override_landing = false
	
func buffer_manage(delta):
	
	if in_hitpause != true:
		if n_light_buffer > 0:
			n_light_buffer -= delta
		if u_light_buffer > 0:
			u_light_buffer -= delta
		if d_light_buffer > 0:
			d_light_buffer -= delta
		if f_light_buffer > 0:
			f_light_buffer -= delta
		if n_special_release_buffer > 0:
			n_special_release_buffer -= delta
		if jump_buffer> 0:
			jump_buffer -= delta
		if l_buffer > 0:
			l_buffer -= delta
		if r_buffer > 0:
			r_buffer -= delta
		if u_buffer > 0:
			u_buffer -= delta
		if d_buffer > 0:
			d_buffer -= delta
	if lock_input == false:
		if Input.is_action_pressed("left"):
				l_buffer = buffer_time
				r_buffer = 0
		if Input.is_action_pressed("right"):
				r_buffer = buffer_time
				l_buffer = 0
		if Input.is_action_pressed("up"):
				u_buffer = buffer_time
				d_buffer = 0
		if Input.is_action_pressed("down"):
				d_buffer = buffer_time
				u_buffer = 0
				
		if Input.is_action_just_pressed("normal_attack"): 
			if attacks_active == true:
				if Input.is_action_pressed("up"):
					u_light_buffer = buffer_time
				elif Input.is_action_pressed("down"):
					d_light_buffer = buffer_time
				elif Input.is_action_pressed("left") || Input.is_action_pressed("right"):
					f_light_buffer = buffer_time
				else:
					n_light_buffer = buffer_time
			else:
				current_interact.clicked()
					
		if Input.is_action_just_pressed("jump"):
			jump_buffer = buffer_time
	if Input.is_action_just_pressed("special_attack"):
		if Input.is_action_pressed("up"):
			u_special_buffer = buffer_time
		elif Input.is_action_pressed("down"):
			d_special_buffer = buffer_time
		elif Input.is_action_pressed("left") || Input.is_action_pressed("right"):
			f_special_buffer = buffer_time
	if Input.is_action_just_released("special_attack"):
		char_visuals.last_charge = charge
		charge = 0
		if attacks_active == true:
			n_special_release_buffer = buffer_time
			
func _process(delta):
	if Input.is_action_pressed("special_attack") && lock_input == false && charge <= 100:
		charge += 35 * delta
		print(charge)
	
	if Input.is_action_just_pressed("special_attack") && interacting == true:
		n_special_release_buffer = 0
		charge = 0
		close_shop()

func _physics_process(delta):
	if lock_input == false:
		input_dir = Input.get_vector("left", "right", "up", "down")
		if ctrl == true:
			direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		else: 
			direction = Vector2.ZERO
		var special_lock = false
		if attacks_active == true:
			if ctrl == true || can_cancel == true && in_hitpause == false && is_hurt == false:
				if u_light_buffer > 0:
					play_anims.emit("Light", "up")
					u_light_buffer = 0
				elif d_light_buffer > 0:
					play_anims.emit("Light", "down")
					d_light_buffer = 0
				elif f_light_buffer > 0:
					play_anims.emit("Light", "fwd")
					f_light_buffer = 0
				elif n_light_buffer > 0:
					play_anims.emit("Light", "")
					n_light_buffer = 0
				elif f_special_buffer > 0:
					play_anims.emit("Heavy", "fwd")
					f_special_buffer = 0
					n_special_release_buffer = 0
					special_lock = true
				elif u_special_buffer > 0:
					play_anims.emit("Heavy", "up")
					u_special_buffer = 0
					n_special_release_buffer = 0
					special_lock = true
				elif d_special_buffer > 0:
					play_anims.emit("Heavy", "down")
					d_special_buffer = 0
					n_special_release_buffer = 0
					special_lock = true
				elif n_special_release_buffer > 0:
					play_anims.emit("Heavy", "")
					n_special_release_buffer = 0
				elif l_buffer > 0 && Input.is_action_just_pressed("left") && ((can_jump == true) && in_hitpause == false) :
					if air_actions > 0:
		#				print("Attempt Dash")
						air_actions -= 1 if is_on_floor() == false else 0
						play_anims.emit("Dash", "")
				elif r_buffer > 0 && Input.is_action_just_pressed("right") && ((can_jump == true) && in_hitpause == false) :
					if air_actions > 0:
		#				print("Attempt Dash")
						air_actions -= 1 if is_on_floor() == false else 0
						play_anims.emit("Dash", "")
#				elif u_buffer > 0 && Input.is_action_just_pressed("up") && ((can_jump == true) && in_hitpause == false) :
#					if air_actions > 0:
#		#				print("Attempt Dash")
#						air_actions -= 1 if is_on_floor() == false else 0
#						play_anims.emit("Dash", "")
#				elif d_buffer > 0 && Input.is_action_just_pressed("down") && ((can_jump == true) && in_hitpause == false) :
#					if air_actions > 0:
#		#				print("Attempt Dash")
#						air_actions -= 1 if is_on_floor() == false else 0
#						play_anims.emit("Dash", "")
				
		
	if lock_input == false:
		buffer_manage(delta)
	
	if is_on_floor() && land == false:
		grounded.emit(true)
	
	if !is_on_floor():
		if is_hurt == false:
			play_anims.emit("Airmove", "")
		land = false
		if fast_fall == false:
			if Input.is_action_pressed("up"):
				velocity.y -= gravity * delta * .7 * gravity_modifier
			else:
				if has_gravity != false:
					velocity.y -= gravity * delta * gravity_modifier
		else: 
			if has_gravity != false:
				velocity.y -= gravity * delta * 2
			
		if Input.is_action_pressed("down") && velocity.y < 5 && attacks_active == true:
			fast_fall = true
			
		if l_wall_sensor.is_colliding() == false && r_wall_sensor.is_colliding() == false:
			gravity_modifier = 1
			wallslide = false
			
		if is_on_wall():
			if ctrl == true && is_hurt == false:
				if l_wall_sensor.is_colliding() && velocity.x <= 0:
					wallslide = true
					play_anims.emit("Wallslide", "")
	#				print("WallSlide")
					gravity_modifier = .1
					if velocity.y > jump_speed/3:
						velocity.y = jump_speed/3
					if Input.is_action_just_pressed("jump") && attacks_active == true:
						velocity.y = jump_speed
				elif r_wall_sensor.is_colliding() && velocity.x >= 0:
					wallslide = true
					play_anims.emit("Wallslide", "")
	#				print("WallSlide")
					gravity_modifier = .1
					if velocity.y > jump_speed/3:
						velocity.y = jump_speed/3
			else: 
				if is_hurt == false:
					play_anims.emit("Fall", "")
				wallslide = false
				gravity_modifier = 1
#	print(direction)
			
	if jump_buffer >0 && ((can_jump == true || ctrl == true) && in_hitpause == false) && is_hurt == false:
		if wallslide == true:
			var wj_calc = wj_height
			if Input.is_action_pressed("down") && attacks_active == true:
				wj_calc = -2
#			elif current_wj_count > 3:
#				wj_calc = wj_height  / current_wj_count
			impulse(walk_speed * (-1 if facing_right == true else 1), wj_calc)
			play_anims.emit("Jump", "")
			_flip()
			wallslide = false
			current_wj_count += 1
			gravity_modifier = 1
			
		elif is_on_floor():
			impulse(velocity.x, jump_speed)
			if is_hurt == false:
				play_anims.emit("Jump", "")
			
		elif air_jumps > 0 && velocity.y < 5 && is_hurt == false:
			impulse(velocity.x, jump_speed)
			air_jumps -= 1
			play_anims.emit("Jump", "")
		
		jump_buffer = 0
	if unit.anim_lock == false:
		if direction.x < 0 && facing_right == true && wallslide == false && can_flip == true && is_hurt == false:
	#		print("Flip Check")
			_flip()
			
		if direction.x > 0 && facing_right == false && wallslide == false && can_flip == true && is_hurt == false:
	#		print("Flip Check")
			_flip()
		
	if direction.x > 0 && velocity.x < 0 && ctrl == true:
		friction *= 2
	elif direction.x < 0 && velocity.x > 0 && ctrl == true:
		friction *= 2
	else:
		friction = 40
		
	if (direction) && wallslide == false && in_hitpause == false && is_hurt == false:
	
		if is_on_floor() && velocity.y == 0:
			play_anims.emit("GroundMove", "") 
		if has_friction == true && unit.anim_lock == false:
			velocity.x = move_toward(velocity.x, direction.x * (walk_speed if is_on_floor() == true else drift_speed), acceleration * delta)
#		velocity.x = direction.x * walk_speed if is_on_floor() == true else direction.x * drift_speed
	else:
		if has_friction == true:
			if is_on_floor() && velocity.y == 0 && is_hurt == false:
				play_anims.emit("Brake", "") if velocity.y == 0 else ""
			velocity.x = move_toward(velocity.x, 0, (friction if is_on_floor() else air_friction) * delta)  

	if movement_paused == false:
		if velocity.y < -30:
			velocity.y = -30
		move_and_slide()

func anim_manager(anim):
	
	char_visuals.animtree.active = false
#	print("Current Anim: ", anim)
	var set_anim = ""
	if anim == "HurtLight":
		set_anim = char_visuals.hurt_light
	elif anim == "HurtHard":
		set_anim = char_visuals.hurt_hard
	elif anim == "HurtBounce":
		set_anim = char_visuals.hurt_bounce
	elif anim == "HurtFall":
		set_anim = char_visuals.hurt_fall
	elif anim == "HurtDown":
		set_anim = char_visuals.hurt_down
	elif anim == "Fall":
		set_anim = char_visuals.fall_anim
	elif anim == "Recover":
		set_anim = char_visuals.recover_air
	else: 
		set_anim = anim
		
	play_anims.emit(set_anim,"Hurt")
	
func store_vel(store):
	if store == true:
		stored_vel.x = velocity.x
		stored_vel.y = velocity.y
		movement_paused = true
		velocity = Vector3.ZERO
		
	else:
		velocity.x = stored_vel.x
		velocity.y = stored_vel.y
		movement_paused = false
		velocity = stored_vel
		
	movement_paused == store

func impulse(speed_x, speed_y):
#	print("Impulse: ", speed_x, " - ", speed_y)
	velocity = Vector3(speed_x, speed_y, 0)
	fast_fall = false

func _flip():
#	("Flip")
	char_visuals.rotation_degrees.y += 180
	facing_right = !facing_right

func end_hitstun():
	is_hurt = false
	ctrl = true
	
	char_visuals.animtree.active = true
	unit.return_neutral()
	
	if is_on_floor():
		play_anims.emit("Brake", "")
	else:
		play_anims.emit("Fall", "")
#	current_state = state_machine.IDLE
#	anim_manager("Idle")

func manage_hurt(hit_info : Move):
#	current_state = state_machine.HURT

	if override_hurt == true:
		anims.play(ov_hurt_anim)
		override_hurt = false
	else:
		hurt_manager.manage_hurt(hit_info)
		is_hurt = true
		ctrl = false
		fast_fall = false


func mod_health(damage):
	print("Damage: ", damage)
	health -= damage if health > damage else health
	health_update.emit()

func interaction_check(check, interactive):
	attacks_active = check
	if check == true:
		current_interact = null
	else:
		current_interact = interactive

func open_shop():
	attacks_active = false
	lock_input = true
	direction = (Vector2.ZERO)
	interacting = true
	shop.active = true
	shop._open_shop(aether)

func close_shop():
	print("Attempting Close")
	attacks_active = true
	lock_input = false
	interacting = false
	shop._hide_shop()
	
func start_dialogue(npc):
	dialogue.open_dialogue(npc.current_dialogue())
	attacks_active = false
	lock_input = true
	direction = (Vector2.ZERO)
	interacting = true

func end_dialogue():
	attacks_active = true
	lock_input = false
	interacting = false

func play_sound(type, strength):
	audio_player.play_sound(type, strength)

func update_aether(count):
	aether += count
	aether_changed.emit()
