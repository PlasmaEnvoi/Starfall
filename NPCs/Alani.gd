extends Node3D

class_name NPC

@export var had_first_interaction: bool = true

@export var intro_dialogue: Array[Dialogue]

@export var standard_interaction_pool: Array[DialoguePool]

@export var used_dialogue: Array[DialoguePool]

func start_interaction(player):
	print(player)
	player.start_dialogue(self)
	
func current_dialogue():
	var passed_dialogue
	if had_first_interaction == false:
		passed_dialogue = standard_interaction_pool.pick_random()
		used_dialogue.append(passed_dialogue)
		standard_interaction_pool.erase(passed_dialogue)
	else:
		had_first_interaction = true
		passed_dialogue = intro_dialogue
	return passed_dialogue
