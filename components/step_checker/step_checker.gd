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


func set_velocity(vel: float):
	wall_check.target_position = global_position + -transform.basis.z.normalized() * vel

func can_step() -> bool:
	if !is_wall_detected():
		if is_floor_detected():
			if !is_ceiling_detected():
				pass
	return false

func is_wall_detected() -> bool:
	wall_check.enabled = true
	wall_check.force_raycast_update()
	wall_check.enabled = false
	if wall_check.is_colliding():
		return true
	return false


func is_floor_detected() -> bool:
	floor_check.enabled = true
	floor_check.force_raycast_update()
	floor_check.enabled = false
	if floor_check.is_colliding():
		return true
	return false


func is_ceiling_detected() -> bool:
	ceiling_check.enabled = true
	ceiling_check.force_raycast_update()
	ceiling_check.enabled = false
	if ceiling_check.is_colliding():
		return true
	return false
