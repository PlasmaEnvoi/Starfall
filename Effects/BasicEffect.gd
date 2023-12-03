extends Node3D

@export var anims: AnimationPlayer
@export var effect_anim: String

func _ready():
	anims.animation_finished.connect(effect_complete)
	play_effect()

func play_effect():
	anims.play(effect_anim)

func effect_complete(anim):
	queue_free()
