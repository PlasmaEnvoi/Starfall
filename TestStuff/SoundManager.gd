extends AudioStreamPlayer3D

@export var attack_sounds: Array[AudioStream]

var audioRNG = RandomNumberGenerator.new()

func play_sound(type, strength):
	
	match type:
		"Slash": 
			stream = attack_sounds[audioRNG.randi_range(0,1)]
			play()
		
		"Charge":
			stream = attack_sounds[2]
			play()
			
		"Hurt":
			stream = attack_sounds[3]
			play()

		"Parry":
			stream = attack_sounds[4]
			play()
			
		"Block":
			stream = attack_sounds[5]
			play()
			
		"Jump":
			stream = attack_sounds[6]
			play()
			
		"Land":
			stream = attack_sounds[7]
			play()
		
		"Dash":
			stream = attack_sounds[8]
			play()
