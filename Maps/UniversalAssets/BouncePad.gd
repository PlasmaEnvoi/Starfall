extends Node3D

@export var player_detect: Area3D
@export var specific_bounce_type: Node3D
@export var velocity: float
@export var anims: AnimationPlayer
@export var vert_severity: int
@export var unlock_anim: String
var room_id = 0

func _ready():
	player_detect.body_entered.connect(player_bounce)
	
func player_bounce(body):
	if body.is_in_group("Player"):
		if body.ctrl == true && body.velocity.y < 0:
			var bounce_calc = specific_bounce_type.calc_bounce(vert_severity, body)
			body.impulse(bounce_calc.x, bounce_calc.y)
			anims.play(specific_bounce_type.bounce_anim)

func unlock():
	specific_bounce_type.unlock()
