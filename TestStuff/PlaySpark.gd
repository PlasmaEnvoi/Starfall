extends Node3D

@export var anims: AnimationPlayer
@export var mesh: MeshInstance3D

func _ready():
	anims.animation_finished.connect(spark_complete)
	play_spark()

func play_spark():
	anims.play("Spark")

func spark_complete(anim):
	queue_free()
