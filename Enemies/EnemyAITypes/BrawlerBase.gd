extends CharacterBody3D

class_name EnemyAI

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var walk_speed = 90.0
var acceleration = 25
var friction = 60
var drift_speed = 8.0
var air_friction = 10
var jump_speed = 12.5
var dash_speed = 12.5
var has_friction: bool = true
var has_gravity: bool = true
var has_bounced: bool = false
var facing_right = false
var can_flip = true
var ctrl = true
var aether = 0
var armored = false
var stored_vel: Vector3
@export var has_hit: bool = false
var in_hitpause: bool = false
var movement_paused: bool = false
var hit_enemies = []

@export var health: int
@export var stagger_percentage: int
@export var patrol_countdown = Timer.new()
@export var attack_cooldown = Timer.new()
var patrol_timer

@export var anims: AnimationPlayer
@export var hurt_manager: Node3D
@export var init_pos : Vector3


@export var unit_type: PackedScene
@export var unit: Node3D
@export var front_ray: RayCast3D
@export var back_ray: RayCast3D

@export var health_bar: ProgressBar
@export var stagger: HScrollBar
@export var bar_display: Sprite3D
@export var unit_scale: Vector3

signal death_info

enum state_machine{
	IDLE,
	FALL,
	PATROL,
	CHASE,
	ATTACK,
	HURT,
	DEAD
}

var current_state: state_machine
var is_hurt = false
var grounded = false
var overriding_land = false
@export var hit_time_label: Label
signal landed

func _ready():
	unit = unit_type.instantiate()
	armored = unit.armored_ready
	global_scale(unit_scale)
	health = unit.base_health
	anims = unit.anims
	unit.main_node = self
	front_ray = unit.l_ray
	back_ray = unit.r_ray
	unit.attack_signal.connect(resolve_attack)
	call_deferred("add_child", unit)
	
#	unit.global_rotation.y += deg_to_rad(90)
	
	init_pos = unit.position
	landed.connect(land_check)
	
	health_bar.max_value = unit.base_health
	health_bar.value =  health
	
	hurt_manager.hurt_time_end.connect(end_hitstun)
	hurt_manager.update_anim.connect(anim_manager)
	
	hurt_manager.main_node = self
	hurt_manager.l_ray = front_ray
	hurt_manager.r_ray = back_ray
	
	patrol_countdown.wait_time = 4
	patrol_countdown.timeout.connect(toggle_patrol)
	patrol_countdown.autostart = true
	
	add_child(patrol_countdown)
	
	attack_cooldown.wait_time = 1
	attack_cooldown.one_shot = true
	attack_cooldown.timeout.connect(cooldown_over)
	
	add_child(attack_cooldown)
	attack_cooldown.stop()
	
	
func land_check():
	print("Landing")
	if overriding_land == true:
		print("Attempting Override: ", unit.current_land_override)
		overriding_land == false
		anim_manager(unit.current_land_override)
	else:
		current_state == state_machine.IDLE
	if is_hurt == true: 
		hurt_manager.hurt_land()
	
func _process(delta):
	hit_time_label.text = str(hurt_manager.hit_timer.time_left)

func _physics_process(delta):
	if current_state != state_machine.DEAD:
		if is_on_floor() && grounded == false:
			landed.emit()
			grounded = true
			
		if is_on_floor() == false:
			grounded = false
			
		match current_state:
			state_machine.IDLE:
				ctrl = true
				anim_manager("Idle")
				if is_on_floor() == true:
					velocity.x = move_toward(velocity.x, 0, friction * delta)  
				else:
					current_state = state_machine.FALL
			state_machine.FALL:
				ctrl = true
				anim_manager("Fall")
				velocity.y -= gravity * delta
				if is_on_floor() == true:
					current_state = state_machine.IDLE
				
			state_machine.PATROL:
				ctrl = true
				if front_ray.is_colliding() && front_ray.get_collider().is_in_group("Wall") && global_position.distance_to(front_ray.get_collision_point()) < 2.3:
					print(global_position.distance_to(front_ray.get_collision_point()))
					_flip()
				anim_manager("Walk")
				velocity.x = walk_speed * delta * (1 if facing_right == true  else -1)
			state_machine.CHASE:
				ctrl = true
				
			state_machine.ATTACK:
	#			print("Attempting Attack")
				if ctrl == true:
					
					anim_manager("Attack")
					
				if is_on_floor() && has_friction == true:
					velocity.x = move_toward(velocity.x, 0, friction * delta)  
				if !is_on_floor():
					if has_gravity == true:
						velocity.y -= gravity * delta
#					current_state = state_machine.FALL
			state_machine.HURT:
				armored = false
				if abs(velocity.x) > 10 && is_on_wall() && hurt_manager.wallbounced == false:
					hurt_manager.init_shake("Wall")
				front_ray.enabled = true
				ctrl = false
				if is_on_floor() && has_friction == true:
					velocity.x = move_toward(velocity.x, 0, friction * delta)  
				else:
					velocity.y -= gravity * delta
	#		main_node.velocity.y -= main_node.gravity * main_node.delta

		if front_ray.is_colliding() == true && ctrl == true && is_on_floor() && current_state != state_machine.ATTACK && front_ray.get_collider().owner.is_in_group("Player"):
			current_state = state_machine.ATTACK
			front_ray.enabled = false
			
	if movement_paused == false:
		move_and_slide()
		
func anim_manager(anim):
#	print("Current Anim: ", anim)
	var playing_hurt = false
	var set_anim = ""
	if anim == "Idle":
		set_anim = unit.idle_anim
	elif anim == "HurtLight":
		set_anim = unit.hurt_light
		playing_hurt = true
	elif anim == "HurtHard":
		set_anim = unit.hurt_hard
		playing_hurt = true
	elif anim == "HurtBounce":
		set_anim = unit.hurt_bounce
		playing_hurt = true
	elif anim == "HurtFall":
		set_anim = unit.hurt_fall
		playing_hurt = true
	elif anim == "HurtDown":
		set_anim = unit.hurt_down
		playing_hurt = true
	elif anim == "Walk":
		set_anim = unit.walk_anim
	elif anim == "Run":
		set_anim = unit.run
	elif anim == "Jump":
		set_anim = unit.jump_anim
	elif anim == "Fall":
		set_anim = unit.fall_anim
	elif anim == "Recover":
		set_anim = unit.recover_air
	elif anim == "Attack":
		set_anim = "Attack"
	elif anim == "Die":
		set_anim = "Die"
		
	else: 
		set_anim = anim
		
		
	if set_anim == "Attack":
		unit.attack()
	elif set_anim == "Die":
		unit.die()
	else:
		if armored == true && playing_hurt == true:
			pass
		else:
			anims.play(set_anim)
	
func manage_hurt(hit_info : Move):
	armored = unit.armored_check(hit_info.move_damage)
	if hit_info.armor_piercing == true:
		armored = false
	if armored == false:
		current_state = state_machine.HURT
	hurt_manager.manage_hurt(hit_info)
	attack_cooldown.stop()
	is_hurt = true
	
func exit_armor():
	if health <= 0:
		die()
	
func end_hitstun():
	if armored == false:
		is_hurt = false
		if health > 0:
			attack_cooldown.start()
			current_state = state_machine.IDLE
			anim_manager("Idle")
		else:
			die()
	else: 
		exit_armor()
		
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


func toggle_patrol():
	patrol_countdown.wait_time = randf_range(3,6)
	if current_state == state_machine.PATROL:
		has_friction = true
		current_state = state_machine.IDLE
	elif current_state == state_machine.IDLE:
		_flip()
		current_state = state_machine.PATROL

func _flip():
	unit.rotation_degrees.y += 180
	facing_right = !facing_right

func resolve_attack(attack_info):
	current_state = state_machine.IDLE

func impulse(speed_x, speed_y):
	if speed_y > 0: 
		grounded == false
#	print("Impulse: ", speed_x, " - ", speed_y)
	velocity = Vector3(speed_x, speed_y, 0)

func cooldown_over():
	print("Cooldownover")
	front_ray.enabled = true
	patrol_countdown.start()
	if is_on_floor() == true && current_state != state_machine.IDLE:
		anim_manager("Idle")
		current_state = state_machine.IDLE
	elif is_on_floor() == false && current_state != state_machine.FALL:
		anim_manager("Fall")
		current_state = state_machine.FALL

func mod_health(damage):
	health -= damage if health > damage else health
	stagger_percentage = unit.get_stagger_percentage()
	stagger.value = stagger_percentage
	bar_display.show()
	health_bar.value = health

func die():
	death_info.emit(self)
	queue_free()
