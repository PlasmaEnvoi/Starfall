extends Resource

class_name Move

enum pos_restrict{
	GROUND,
	AIR,
	ATTACKING,
	HIT,
	BLOCK,
	COUNTER
}

enum move_strengths{
	NORMAL_A,
	NORMAL_B,
	NORMAL_C,
	SPECIAL,
	SUPER
}

enum damage_directions {
	BACK,
	FORWARD,
	UP,
	DOWN
}

enum hit_flags{
	HIGH,
	MEDIUM,
	LOW,
	AIR,
	FALL,
	ALL
}
enum target_flags{
	HIGH,
	MID,
	LOW,
	FALL,
	DOWN,
	ALL
}

enum hit_type{
	LIGHT,
	HARD,
	GRAB,
	FLINCH,
	LAUNCH,
	SPIKE
}

enum priority_type{
	ATTACK,
	DASH,
	DODGE,
	BLOCK,
	COUNTER
}

enum effect_strength{
	LIGHT,
	MEDIUM,
	HEAVY,
	RAPID
}

enum effect_type{
	SLASH,
	PIERCE,
	BLUNT,
	GUARD
}

enum abilities{
	
}

@export_group ("Move Properties")
@export var move_name: String
@export var move_strength: move_strengths
@export var interaction_type: priority_type
@export var move_type: abilities
@export var move_owner: Node3D
@export var give_meter: int
@export var take_meter: int

@export_group("Movement")
@export var halt_movement: bool
@export var halt_gravity: bool

@export_group("Damage Info")
@export var damaging: bool
@export var hits_once: bool
@export var force_facing: bool
@export var neutral_dir: bool
@export var jump_cancel: bool
@export var cancel_level: int

@export_subgroup("Main Info")
@export var spark_pos: Vector2 = Vector2.ZERO
@export var spark_rot: int
@export var move_damage: int
@export var aggrressor_hitpause: int
@export var reciever_hitpause: int
@export var guard_pause: int
@export var numhits: int = 1
@export var spark_strength: effect_strength
@export var spark_type: effect_type
@export var armor_piercing: bool
@export var hit_properties: hit_flags
@export var can_hit: target_flags
@export var ground_anim_type: hit_type
@export var air_anim_type: hit_type
@export var down_anim_type: hit_type

@export_subgroup("Trigger Info")
@export var launch: bool
@export var knockdown: bool
@export var bounce: bool
@export var juggle_cost: int
@export var can_juggle: bool
@export var hit_shake: int
@export var hit_sound: AudioStream #Feel free to change this, idk how audio works at all so if another thing is better lemme know

@export_subgroup("Hit Movement")
@export var ground_vel: Vector2
@export var air_vel: Vector2
@export var down_vel: Vector2
@export var hurt_vel: Vector2
@export var bounce_vel: Vector2
@export var custom_gravity: bool = false
@export var fall_gravity: Vector2
@export var ground_hit_time: float = -1
@export var air_hit_time: float = -1
@export var down_hit_time: float = -1
@export var fall_hit_time: float = -1
