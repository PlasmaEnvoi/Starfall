extends Resource

class_name Dialogue

@export_group("Actor 1 Info")
@export var actor_1_portrait: AtlasTexture
@export var actor_1_name: String
@export var actor_1_title: String
@export var actor_1_sound: AudioStream
@export var actor_1_expression: String


@export_group("Actor 2 Info")
@export var actor_2_portrait: AtlasTexture
@export var actor_2_name: String
@export var actor_2_title: String
@export var actor_2_sound: AudioStream
@export var actor_2_expression: String

enum speaker{
	ACTOR_1,
	ACTOR_2,
	NEITHER,
	BOTH
}

@export_group("Dialogue")
@export_multiline var current_line
@export var current_speaker: speaker
