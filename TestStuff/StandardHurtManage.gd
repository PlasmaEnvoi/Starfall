extends Node3D

@export var main_node: Node3D
@export var shake_severity: int = 15
@export var current_hurtbox_info: Move
@export var l_ray: RayCast3D
@export var r_ray: RayCast3D

var shaking = false
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var shake_timer
var wall_shake_timer
var hit_timer
var grounded = false
var done_hurt_impulse = false
var resolving_launch = false
var has_bounced = false
var knocked_down = false
var wallbounced = false

signal hurt_time_end
signal update_anim(anims)

func _ready():
	shake_timer = Timer.new()
	shake_timer.one_shot = true
	shake_timer.timeout.connect(shake_over)
	add_child(shake_timer)
	
	wall_shake_timer = Timer.new()
	wall_shake_timer.one_shot = true
	wall_shake_timer.timeout.connect(wall_bounce)
	add_child(wall_shake_timer)
	
	hit_timer = Timer.new()
	hit_timer.one_shot = true
	hit_timer.timeout.connect(hurt_over)
	add_child(hit_timer)
	
	
func _physics_process(delta):
	if shaking == true:
		shake()
	
func manage_hurt(hurt_info: Move):
	var damage = hurt_info.move_damage
	wallbounced = false
#	print("===================================")
	has_bounced = false
#	print(hurt_info.move_name)
	current_hurtbox_info = hurt_info
	main_node.mod_health(damage)
	
	shake_timer.wait_time = current_hurtbox_info.reciever_hitpause/50.0
	
	if main_node.is_on_floor():
		hit_timer.wait_time = current_hurtbox_info.ground_hit_time/50.0
		
	elif main_node.is_on_floor() == false:
		if current_hurtbox_info.knockdown == false:
			hit_timer.wait_time = current_hurtbox_info.air_hit_time/50.0
		else:
			knocked_down = true
			hit_timer.wait_time = 999.0
#	print(hurt_info.hit_type.keys())
	if hurt_info.hit_type.keys()[hurt_info.ground_anim_type] == "LIGHT":
		update_anim.emit("HurtLight")
	elif hurt_info.hit_type.keys()[hurt_info.ground_anim_type] == "HARD":
		update_anim.emit("HurtHard")
	elif hurt_info.hit_type.keys()[hurt_info.ground_anim_type] == "LAUNCH":
		update_anim.emit("HurtFall")
	elif hurt_info.hit_type.keys()[hurt_info.ground_anim_type] == "SPIKE":
		update_anim.emit("HurtSpike")
	init_shake("Standard")
	
func init_shake(type):
#	print("CheckShake")
	
	match type:
		"Standard":
			shake_timer.start()
		"Wall":
			wallbounced = true
			wall_shake_timer.wait_time = .05
			wall_shake_timer.start()
	hit_timer.stop()
	shaking = true
	done_hurt_impulse = false
	main_node.movement_paused = true
	
	
func shake():
	main_node.unit.position.x = (randf_range(-shake_severity,shake_severity))/100.0
	main_node.unit.position.y = main_node.init_pos.y + (randf_range(-shake_severity,shake_severity))/100.0
	main_node.anims.pause()
	
func shake_over():
#	print("CheckShakeEnd")
	main_node.anims.play()
	shaking = false
	main_node.movement_paused = false
	main_node.unit.position = main_node.init_pos
	done_hurt_impulse = true
	hit_timer.start()
	hurt_launch()
	
func hurt_launch():
#	print("CheckLaunch")
	if done_hurt_impulse == true:
		if current_hurtbox_info.launch == true && main_node.is_on_floor() == true:
			update_anim.emit("HurtFall")
#			print("Was on ground", current_hurtbox_info.ground_vel)
			grounded = false
			main_node.velocity = Vector3(current_hurtbox_info.ground_vel.x, current_hurtbox_info.ground_vel.y, 0)
			
		elif main_node.is_on_floor() == false:
			update_anim.emit("HurtFall")
#			print("Was in Air", current_hurtbox_info.air_vel)
			grounded = false
			main_node.velocity = Vector3(current_hurtbox_info.air_vel.x, current_hurtbox_info.air_vel.y, 0)
		else:
#			print("No Launch", current_hurtbox_info.ground_vel)
			main_node.velocity = Vector3(current_hurtbox_info.ground_vel.x, current_hurtbox_info.ground_vel.y, 0)
#		print("LaunchImpulse: ", main_node.velocity.x, " - ", main_node.velocity.y)
		
func hurt_land():
#	print("Fall Reset?")
	if current_hurtbox_info.bounce == true && has_bounced == false:
#		print("Bounce")
		hit_timer.wait_time = 3.0
		hit_timer.start()
		main_node.velocity = Vector3(main_node.velocity.x,current_hurtbox_info.bounce_vel.y, 0)
		update_anim.emit("HurtBounce")
		main_node.grounded = false
		knocked_down = true
		has_bounced = true
	else: 
#		print("land")
		hit_timer.wait_time = .8
		hit_timer.start()
		update_anim.emit("HurtDown")
		main_node.velocity = Vector3(current_hurtbox_info.bounce_vel.x,0, 0)
		
func hurt_over():
	hurt_time_end.emit()
	
func wall_bounce():
	main_node.anims.play()
	shaking = false
	main_node.movement_paused = false
	main_node.unit.position = main_node.init_pos
	done_hurt_impulse = true
	wall_bounce_launch()

func wall_bounce_launch():
	update_anim.emit("HurtFall")
#	print("Attempt Wallbounce")
	main_node.velocity = Vector3(-current_hurtbox_info.ground_vel.x * .3, 9, 0)
