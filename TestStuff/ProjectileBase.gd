extends CharacterBody3D

class_name BasicProjectile

@export var hitbox_info: Move
@export var proj_vel: Vector3
@export var point_dir: bool
@export var hitbox: Area3D
@export var projectile_info: ProjectileData
@export var basic_hitspark: PackedScene
@export var facing_right = true
@export var anims: AnimationPlayer
@export var hit_list: Array[String]
@export var proj_owner: Node3D

var kill_timer = Timer.new()

var movement_paused = false
var stored_vel: Vector3
var in_hitpause
signal projectile_contact
signal play_sound

func _ready():
	hitbox.area_entered.connect(detected_hit)
	

func establish_data(projectile_data: ProjectileData):
	print(projectile_data.charge)
	projectile_info = projectile_data.duplicate()
	proj_vel =( projectile_info.proj_vel * (1 + projectile_info.charge/100))
	if facing_right == false:
		proj_vel.x *= -1
	hitbox_info = projectile_info.proj_info.duplicate()
	point_dir = projectile_info.points_at_vel
	hitbox_info.move_damage *= (.75 + projectile_info.charge/100)
	if facing_right == false:
		hitbox_info.ground_vel.x *= -1
		hitbox_info.air_vel.x  *= -1
		hitbox_info.down_vel.x *= -1
		hitbox_info.hurt_vel.x *= -1
	
#	kill_timer = Timer.new()

	kill_timer.wait_time = .75 + (projectile_info.charge/50)
	kill_timer.timeout.connect(end_projectile)
	kill_timer.autostart = true
	
	add_child(kill_timer)
	
	
func _physics_process(delta):
	velocity = proj_vel
	
	if is_on_floor():
		end_projectile()
	if is_on_wall():
		end_projectile()
	if is_on_ceiling():
		end_projectile()
	
	if movement_paused == false:
		move_and_slide()

func detected_hit(target):
	var viable_target = false
	print("Proj hit")
	print(hit_list)
	print(target.owner)
	if target.is_in_group("Projectile") == false || target.is_in_group("Stage") == false:
		for i in hit_list:
			print(target.owner.main_node.get_groups())
			if target.owner.main_node.is_in_group(i):
				viable_target = true
		if viable_target == true:
			if projectile_info.hit_count > 1:
				resolve_hit(target)
			else:
				resolve_hit(target)
				end_projectile()
	else: 
		if target.is_in_group("Stage"):
			end_projectile()
		if target.is_in_group("Projectile"):
			end_projectile()
		

func resolve_hit(target):
	create_spark(basic_hitspark)
	projectile_info.hit_count -= 1
	hit_pause([anims.get_current_animation(),anims.get_current_animation_position()]) 
	target.owner.main_node.manage_hurt(hitbox_info)
	
func create_spark(basic_hitspark):
	var new_spark = basic_hitspark.instantiate()
	get_tree().root.add_child(new_spark)
	new_spark.global_position.x = global_position.x + hitbox_info.spark_pos.x/100.0 * ( -1 if facing_right == false else 1)
	new_spark.global_position.y = global_position.y + hitbox_info.spark_pos.y/100.0
	new_spark.rotation_degrees.x = hitbox_info.spark_rot
	
func hit_pause(current_anim_data):
	anims.pause()
	await get_tree().create_timer(hitbox_info.aggrressor_hitpause/50.0).timeout
	in_hitpause = false
	store_vel(false)
	anims.play()

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

func end_projectile():
	queue_free()

func emit_sound(sound, strength):
	play_sound.emit(sound, strength)
