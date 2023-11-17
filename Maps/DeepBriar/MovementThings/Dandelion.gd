extends Node3D

@export var bounce_anim: String
@export var impulse_strength_x: float
@export var impulse_strength_y: float = 11


func calc_bounce(vert_severity, body):
	var bounce_vel = Vector2(body.velocity.x *.7, impulse_strength_y * vert_severity)
	return bounce_vel
