class_name FollowCamera
extends Camera3D

@export var camera_guide: Node3D 
@export var look_at_target: Node3D
@export var follow_speed : float = 5.0 


func _ready():
	make_current()
	pass


func _process(delta):
	if look_at_target and camera_guide:
		global_position = lerp(global_position, camera_guide.global_position, follow_speed * delta)
		look_at(look_at_target.global_position)
