class_name StepChecker
extends Node3D

@onready var wall_check: RayCast3D = $WallCheck
@onready var floor_check: RayCast3D = $FloorCheck
@onready var ceiling_check: RayCast3D = $CeilingCheck

@export var character_height: float = 2.0
@export var step_height: float = 0.25

var parent: Node3D = null


func _ready():
	parent = get_parent()
	wall_check.add_exception(parent)
	floor_check.add_exception(parent)
	wall_check.add_exception(parent)


# Uses raycasts to see if a valid step is in the direction of desired direction
# Returns the relative position to step to
func can_step(desired_dir: Vector3, _delta: float) -> Vector3:
	# This is a top level object, so move to where it belongs on the character
	# We are top level to avoid inheriting rotations
	global_position = parent.global_position + Vector3(0, character_height / 2, 0)
	
	# Move raycasts in the direction of input direction
	wall_check.position = Vector3.ZERO
	wall_check.target_position = desired_dir
	floor_check.position = wall_check.position + wall_check.target_position
	floor_check.target_position = -Vector3.UP * character_height
	ceiling_check.position = wall_check.position + wall_check.target_position
	ceiling_check.target_position = Vector3.UP * character_height
	
	var floor_pos: Vector3 = Vector3.ZERO
	if is_wall_detected():
#		print("Wall is blocking: ", wall_check.get_collider())
		return Vector3.ZERO
	
	if !is_floor_detected():
#		print("No floor to step on")
		return Vector3.ZERO
	else:
		# Global position of where the floor check hits
		floor_pos = floor_check.get_collision_point()
	
	if is_ceiling_detected():
		var ceiling_pos = ceiling_check.get_collision_point() # Global coords
		
		# Is there enough room between the floor and ceiling to step to?
		if ceiling_pos.distance_to(floor_pos) < character_height:
#			print("No room for head")
			return Vector3.ZERO
		else:
#			print("Step to floor pos: ", floor_pos)
			return floor_pos
	else:
#		print("Step to floor pos: ", floor_pos)
		return floor_pos


func is_wall_detected() -> bool:
#	wall_check.enabled = true
	wall_check.force_raycast_update()
#	wall_check.enabled = false
	if wall_check.is_colliding():
		return true
	return false


func is_floor_detected() -> bool:
#	floor_check.enabled = true
	floor_check.force_raycast_update()
#	floor_check.enabled = false
	if floor_check.is_colliding():
		return true
	return false


func is_ceiling_detected() -> bool:
#	ceiling_check.enabled = true
	ceiling_check.force_raycast_update()
#	ceiling_check.enabled = false
	if ceiling_check.is_colliding():
		return true
	return false
