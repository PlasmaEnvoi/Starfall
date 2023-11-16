extends Control

@export var current_script: Array[Dialogue]
@export var test_script: Array[Dialogue]
@export var actor_1_portrait: TextureRect
@export var actor_2_portrait: TextureRect
@export var speaker_name: Label
@export var speaker_title: Label
@export var dialogue_box: Label
var dialogue_active: bool = false
var currently_advancing = false

# Dialogue Audio Stuff
#different positions (in seconds) of the audio track in dialogueAudioPlayer
var dialogueAudioPositions = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0]
#pitches the audio up and down at random
var audioPitchRange = [0.0,3.0]
#random number generator for generating random audio positions and pitches
var audioRNG = RandomNumberGenerator.new()

@export var current_dialogue: Dialogue
var skip_crawl = false

func _ready():
	hide()
	
func _process(delta):
	if Input.is_action_just_pressed("normal_attack") && dialogue_active == true:
		if currently_advancing == false:
			if current_script.is_empty():
				print("Ending")
				end_dialogue()
			else:
				print("Next Panel")
				advance_dialogue()
		else: 
			print("Skipping")
			skip_crawl = true
	if Input.is_action_just_pressed("special_attack"):
		open_dialogue(test_script)

func open_dialogue(new_dialogue_prompt: Array[Dialogue]):
	dialogue_active = true
	current_script.clear()
	current_script = new_dialogue_prompt.duplicate()
	advance_dialogue()
	show()
	
func advance_dialogue():
	var set_script = current_script.pop_front()
	actor_1_portrait.texture = set_script.actor_1_portrait
	actor_2_portrait.texture = set_script.actor_2_portrait
	actor_2_portrait.flip_h = true
	
	var current_actor = 0
#Actor 1  : 0
# Actor 2 : 1
# Neither : 2
#    Both : 3
	current_actor = set_script.current_speaker
	print(current_actor)
	match  current_actor:
		0:
			speaker_name.text = set_script.actor_1_name
			speaker_title.text = set_script.actor_1_title
			actor_1_portrait.modulate = Color(1,1,1,1)
			actor_2_portrait.modulate = Color(1,1,1,.3)
		1:
			speaker_name.text = set_script.actor_2_name
			speaker_title.text = set_script.actor_2_title
			actor_1_portrait.modulate = Color(1,1,1,.3)
			actor_2_portrait.modulate = Color(1,1,1,1)
		2:
			speaker_name.text = ""
			speaker_title.text = ""
			actor_1_portrait.modulate = Color(1,1,1,.3)
			actor_2_portrait.modulate = Color(1,1,1,.3)
		3:
			speaker_name.text = "Both"
			speaker_title.text = ""
			actor_1_portrait.modulate = Color(1,1,1,1)
			actor_2_portrait.modulate = Color(1,1,1,1)
			
	var letter_count = 0
	var new_dialogue = ""
	var dialogue_array = []
	currently_advancing = true
	for character in set_script.current_line:
		if skip_crawl == false:
			#random number generator to determine which vowel will play from the audio file
			var pitch = audioRNG.randf_range(audioPitchRange[0], audioPitchRange[1])
			var audioPosition = audioRNG.randi_range(0, dialogueAudioPositions.size()-1)
			#these play audioplayer - sets the pitch first then plays at random position
			$DialogueAudioPlayer.set_pitch_scale(pitch)
			#random number generator to determine pitch of the audio
			$DialogueAudioPlayer.play(dialogueAudioPositions[audioPosition])
			await get_tree().create_timer(.01).timeout
			#stops the audioplayer after .01 seconds
			$DialogueAudioPlayer.stop()
			
		new_dialogue += character
		dialogue_box.text = new_dialogue
	currently_advancing = false
	skip_crawl = false
		
func end_dialogue():
	hide()
	dialogue_active = false
