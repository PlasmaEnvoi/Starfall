extends CharacterBody3D


const SPEED = 14.0
const JUMP_VELOCITY = 10.5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var walk_speed = 8.0
var acceleration = 25
var friction = 60
var drift_speed = 8.0
var air_friction = 10
var jump_speed = 12.5
var dash_speed = 12.5
var movement_paused: bool = false
var friction_on: bool = true
var has_bounced: bool = false
var facing_right = false

@export var anims: AnimationPlayer
@export var animtree: AnimationTree
@export var hurt_manager: Node3D
@export var char_visuals: Node3D
@export var init_pos : Vector3


@export var idle_anim: String
@export var hurt_light: String
@export var hurt_hard: String
@export var hurt_fall: String
@export var hurt_spike: String
@export var hurt_down: String
@export var hurt_bounce: String

@export var l_ray: RayCast3D
@export var r_ray: RayCast3D

enum state_machine{
	IDLE,
	CHASE,
	ATTACK,
	HURT
}

var current_state: state_machine
var is_hurt = false
var grounded = false
signal landed

func _ready():
	init_pos = char_visuals.position
	landed.connect(land_check)
	hurt_manager.l_ray = l_ray
	hurt_manager.r_ray = r_ray
	
func land_check():
	if is_hurt == true: 
		hurt_manager.hurt_land()
	

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_select"):
		_flip()
	
	
	if current_state == state_machine.HURT && abs(velocity.x) > 10 && is_on_wall() && hurt_manager.wallbounced == false:
		hurt_manager.init_shake("Wall")
	
	if is_on_floor() && grounded == false:
		landed.emit()
		grounded = true
		
	if is_on_floor() == false:
		grounded = false
		
	match current_state:
		state_machine.IDLE:
			if is_on_floor() && friction_on == true:
				velocity.x = move_toward(velocity.x, 0, friction * delta)  
		state_machine.CHASE:
			pass
		state_machine.ATTACK:
			if is_on_floor() && friction_on == true:
				velocity.x = move_toward(velocity.x, 0, friction * delta)  
		state_machine.HURT:
			if is_on_floor() && friction_on == true:
				velocity.x = move_toward(velocity.x, 0, friction * delta)  
			else:
				velocity.y -= gravity * delta
#		main_node.velocity.y -= main_node.gravity * main_node.delta

	if movement_paused == false:
		move_and_slide()
		
func anim_manager(anim):
#	print("Current Anim: ", anim)
	var set_anim = ""
	if anim == "Idle":
		set_anim = idle_anim
	elif anim == "HurtLight":
		set_anim = hurt_light
	elif anim == "HurtHard":
		set_anim = hurt_hard
	elif anim == "HurtBounce":
		set_anim = hurt_bounce
	elif anim == "HurtFall":
		set_anim = hurt_fall
	elif anim == "HurtDown":
		set_anim = hurt_down
	
	anims.play(set_anim)
	
func manage_hurt(hit_info : Move):
	current_state = state_machine.HURT
	hurt_manager.manage_hurt(hit_info)
	is_hurt = true
#	action.action_data.action_type.keys()[action.action_data.animation]
#	LIGHT,
#	HARD,
#	GRAB,
#	FLINCH,
#	LAUNCH,
#	SPIKE
	
func end_hitstun():
	is_hurt = false
	current_state = state_machine.IDLE
	anim_manager("Idle")


func _flip():
	char_visuals.rotation_degrees.y += 180
	facing_right = !facing_right
