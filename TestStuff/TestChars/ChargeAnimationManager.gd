extends Node3D

@export var anims: AnimationPlayer
@export var charge_particles: CPUParticles3D
@export var light: OmniLight3D
@export var charge_circle: MeshInstance3D

func _ready():
	hide()
	
func stop_charge():
	charge_particles.emitting = false
	anims.stop()
	hide()

func start_charge(charge):
	if charge < 66:
		charge_circle.hide()
		charge_particles.emitting = true
	else:
		charge_circle.show()
		anims.play("Charging")
	show()
