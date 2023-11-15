extends Node3D

@export var crystal: Node3D
@export var player_interaction: Area3D

signal can_activate_beacon

func _ready():
	player_interaction.body_entered.connect(enable_exit)
	player_interaction.body_exited.connect(disable_exit)
	
func _process(delta):
	crystal.rotation_degrees.y += delta * 40

func enable_exit(player):
	player.interaction_check(false, self)
	
func disable_exit(player):
	player.interaction_check(true, self)

func clicked():
	print("Pressed!")
