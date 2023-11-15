extends AudioStreamPlayer3D

@export var attack_sounds: Array[AudioStream]

func play_sound(type, strength):
	
	match type:
		"Slash": 
			stream = attack_sounds[0]
			play()
