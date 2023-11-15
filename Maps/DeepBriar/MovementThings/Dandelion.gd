extends Node3D

@export var bounce_anim: String
@export var impulse_strength_x: float
@export var impulse_strength_y: float = 30


func calc_bounce(body):
	var bounce_vel = Vector2(body.velocity.x *.7, impulse_strength_y)
	return bounce_vel
