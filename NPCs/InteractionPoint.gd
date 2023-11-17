extends Node3D

@export var interact_object: Node3D
@export var player_interaction: Area3D

@export var player: Node3D

signal can_interact

func _ready():
	player_interaction.body_entered.connect(enable_interaction)
	player_interaction.body_exited.connect(disable_interaction)

func enable_interaction(body):
	player = body
	player.interaction_check(false, self)
	
func disable_interaction(body):
	player = body
	player.interaction_check(true, self)

func clicked():
	print("Pressed!")
	interact_object.start_interaction(player)
	player.start_dialogue(interact_object)
