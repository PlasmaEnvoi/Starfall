extends Node3D

class_name EnemyUnit

@export var anims: AnimationPlayer
@export var main_node: CharacterBody3D
@export var unit_name: String
@export var unit_weight: int
@export var base_health: float
@export var max_health: float
@export var stagger_percentage: float
@export var down_time: float
@export var unit_visuals: GruntVisuals
@export var anim_lock: bool = false

@export_group("Nodes")
@export var l_ray: RayCast3D
@export var r_ray: RayCast3D
@export var d_sensor: RayCast3D
@export var hurtbox: Area3D
@export var hitbox_a: Area3D
@export var hitbox_b: Area3D
@export var hitbox_c: Area3D
@export var current_hitbox_data: Move

@export_group("AttackFX")
@export var slash: Node3D
@export var unit_fx: PackedScene
@export var basic_hitspark: PackedScene

@export_group("Universals")
@export var idle_anim: String
@export var walk_anim: String
@export var jump_anim: String

@export_group("Hurts")
@export var hurt_light: String
@export var hurt_hard: String
@export var hurt_fall: String
@export var hurt_spike: String
@export var hurt_down: String
@export var hurt_bounce: String
@export var recover_air: String
@export var fall_anim: String

@export_group("Attacks")
@export var attack_actions: Array[String]

@export_group("Drops")
@export var aether_drop_mod: int = 2

@export_group("Signals")
signal attack_possible
signal attack_signal
signal hit_completed

func _ready():
	anims.animation_finished.connect(_end_anims)
	anims.playback_default_blend_time = .07
	hitbox_a.area_entered.connect(detected_hit)
	unit_visuals.randomize_unit()
	max_health = base_health
	
func get_stagger_percentage():
	return stagger_percentage
	
func armored_ready():
	return true
	
func armored_check():
	print( "Stagger Check: ", float(main_node.health/max_health) * 100)
	print("Stagger Percentage: ", stagger_percentage)
	return (main_node.health/max_health * 100) > stagger_percentage
	
func attack():
	if main_node.ctrl == true && attack_actions.find(anims.get_current_animation()) == -1:
#		print("Attempt Swing")
		unit_visuals.did_combo = false
		unit_visuals.current_anim = unit_visuals.get_attack_anim()
		anims.play(unit_visuals.current_anim)

func movement_impulse(movement: Vector2, has_friction: bool, has_gravity: bool):
	if main_node.facing_right == false:
		movement.x *= -1
	main_node.impulse(movement.x, movement.y)
	main_node.has_gravity = has_gravity
	main_node.has_friction = has_friction
	

func establish_hitbox_info(info: Move):
	main_node.ctrl = false
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
	if current_hitbox_data.hits_once == true && main_node.has_hit == false:
		resolve_hit(target)
	elif current_hitbox_data.hits_once != true:
		resolve_hit(target)
		
func resolve_hit(target):
		main_node.has_hit = true
		create_spark(basic_hitspark)
		hit_pause([anims.get_current_animation(),anims.get_current_animation_position()]) 
		target.owner.main_node.manage_hurt(current_hitbox_data)
	
func hit_pause(current_anim_data):
	anims.pause()
	main_node.store_vel(true)
	main_node.in_hitpause = true
	await get_tree().create_timer(current_hitbox_data.aggrressor_hitpause/50.0).timeout
	hit_completed.emit(current_hitbox_data)
	main_node.in_hitpause = false
	main_node.store_vel(false)
	anims.play()
	current_hitbox_data
	
func return_neutral():
	hitbox_a.monitoring = false
	hitbox_b.monitoring = false
	hitbox_c.monitoring = false
	main_node.has_hit = false
	slash.hide()
	main_node.can_flip = true
	main_node.has_friction = true
	main_node.has_gravity = true
	anim_lock = false
	_reset_anim()

func _reset_anim():
	pass
		
func _end_anims(anim_name):
#	print("Attempt End Animation")
	if main_node.ctrl == true:
		return_neutral()
	print(attack_actions.find(anim_name))
	if attack_actions.find(anim_name) != -1 && main_node.ctrl == false:
			print("Start Cooldown")
			main_node.current_state = main_node.state_machine.IDLE if main_node.is_on_floor() == true else main_node.state_machine.FALL
			main_node.attack_cooldown.start()
			
