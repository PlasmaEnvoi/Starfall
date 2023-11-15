extends Camera3D

@export_category("Follow this node")
@export var cam_target : Node3D   #THE CAMERA WILL FOLLOW THIS NODE
@export_category("Wait Time")
@export var wait_time : float   #How long for the camera to start following the node, can leave it at 0 too
var point_position : Vector3    #The global position of the node we want the camera to follow
@export var speed := 2.0    #How fast the camera will reach its destination
@export var tracking = false
 
# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true)   #Prevents the camera from being glued to the player (won't follow on its own)
	tracking = true
 
func _process(delta):
	if tracking == true:
		follow_player(delta)
	
 
func follow_player(delta):
	var direction = self.global_position - cam_target.global_position 
	var point_current_position = point_position
	var point_last_position = cam_target.global_position
	
	if point_last_position != point_current_position:
		await get_tree().create_timer(wait_time).timeout
		self.transform.origin -= direction * speed * delta
