extends Node3D

@export var bounce_anim: String
@export var impulse_strength_x: float
@export var impulse_strength_y: float = 11
@export var anims: AnimationPlayer


func calc_bounce(vert_severity, body):
	var bounce_vel = Vector2(body.velocity.x *.7, impulse_strength_y * vert_severity)
	return bounce_vel
	
func unlock():
	change_anim("Dandelion_Spawn")
	
func change_anim(anim : String):
	anims.play(anim)
