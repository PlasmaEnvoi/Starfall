extends Node3D

@export var crystal: Node3D

@export var light: OmniLight3D
@export var player_interaction: Area3D
@export var player: Node3D

@export var ring1: Node3D
@export var ring2: Node3D
@export var ring3: Node3D

func _ready():
	position.y += 8
	player_interaction.body_entered.connect(enable_shop)
	player_interaction.body_exited.connect(disable_shop)

func _process(delta):
	crystal.rotation_degrees.x -= delta * 50
	crystal.rotation_degrees.y += delta * 50
	ring1.rotation_degrees.x += delta * 120
	ring2.rotation_degrees.z -= delta * 80
	ring3.rotation_degrees.x -= delta * 20
	
func enable_shop(body):
	player = body
	player.interaction_check(false, self)
	
func disable_shop(body):
	player = body
	player.interaction_check(true, self)

func clicked():
	print("Pressed!")
	player.open_shop()
	
