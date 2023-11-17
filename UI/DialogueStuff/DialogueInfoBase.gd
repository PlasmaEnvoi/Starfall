extends Resource

class_name Dialogue

enum actor_expressions{
	IDLE,
	HAPPY,
	SAD,
	ANGRY,
	CONFUSED,
	TIRED,
	SURPRISED,
	EXCITED,
	COMBAT_READY
}
@export_group("Actor 1 Info")
@export var actor_1_portrait: AtlasTexture
@export var actor_1_name: String
@export var actor_1_title: String
@export var actor_1_sound: AudioStream
@export var actor_1_expression: actor_expressions


@export_group("Actor 2 Info")
@export var actor_2_portrait: AtlasTexture
@export var actor_2_name: String
@export var actor_2_title: String
@export var actor_2_sound: AudioStream
@export var actor_2_expression: actor_expressions

enum speaker{
	ACTOR_1,
	ACTOR_2,
	NEITHER,
	BOTH
}

@export_group("Dialogue")
@export_multiline var current_line
@export var current_speaker: speaker
