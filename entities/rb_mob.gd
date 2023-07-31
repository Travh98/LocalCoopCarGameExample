class_name RbMob
extends RigidBody3D

## Base Mob class using CharacterBody3D
##
## All mobs will inherit from this, handles basic living being components

# Movement Variables
var gravity_multiplier := 10.0
var speed: float = 3
var acceleration: float = 8
var deceleration: float = 10
var jump_height: float = 10
var angular_speed = 5.0
@onready var gravity: float = (ProjectSettings.get_setting("physics/3d/default_gravity") 
		* gravity_multiplier)
var direction := Vector3()

# Components
@onready var health_component: HealthComponent = $HealthComponent
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

@onready var ground_check: RayCast3D = $GroundCheck
var rolling_ground_check_array: Array[bool]
var rolling_ground_check_size: int = 1


func _ready():
	health_component.health_died.connect(on_death)
	nav_agent.velocity_computed.connect(on_nav_velocity_computed)
	gravity_scale = 0
	
	print("Creating class RbMob")


func _integrate_forces(state):
	pass


func apply_gravity(delta):
	if !is_on_floor():
		apply_central_force(-Vector3.UP * gravity * delta)


func apply_movement():
	# I think we don't need this, since move and slide relies on Velocity, which
	# is set through all the central force functions
#	move_and_slide()
	pass


func prevent_y_axis_rotation():
	rotation_degrees.x = 0
	rotation_degrees.z = 0


func apply_jump():
	apply_impulse(global_transform.basis.y.normalized() * jump_height)


func on_nav_velocity_computed(safe_velocity: Vector3):
	linear_velocity = linear_velocity.move_toward(safe_velocity, 0.25)


func apply_nav_agent_velocity():
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized()
	nav_agent.set_velocity(new_velocity * speed)


func accelerate(delta: float) -> void:
	# Using only the horizontal velocity, interpolate towards the input.
	var temp_vel := linear_velocity
	temp_vel.y = 0
	
	var temp_accel: float
	var target: Vector3 = direction * speed
	
	if direction.dot(temp_vel) > 0:
		temp_accel = acceleration
	else:
		temp_accel = deceleration
	
	temp_vel = temp_vel.lerp(target, temp_accel * delta)
	
	linear_velocity.x = temp_vel.x
	linear_velocity.z = temp_vel.z


func on_death():
	global_position = Vector3.ZERO
	linear_velocity = Vector3.ZERO
	health_component.full_heal()


func rotate_towards_motion(delta: float) -> void:
	# Rotate so we are facing direction
	var current_direction := -global_transform.basis.z

	# Get the axis to rotate on
	var axis := current_direction.cross(direction).normalized()
	# Make sure its not zero
	if axis == Vector3.ZERO:
		return
	var angle := current_direction.signed_angle_to(direction, axis)
	var angle_step: float = min(angular_speed * delta, abs(angle)) * sign(angle)
	rotate(axis, angle_step)


func rotate_towards_motion_no_y(delta: float):
	# Rotate so caller is facing the position
	var current_direction := -global_transform.basis.z
	# Get the axis to rotate on
	var axis := Vector3.UP
	# Make sure its not zero
	if axis == Vector3.ZERO:
		return
	var angle := current_direction.signed_angle_to(direction, axis)
	var angle_step: float = min(angular_speed * delta, abs(angle)) * sign(angle)
	rotate(axis, angle_step)


func is_on_floor():
	# Check if ground raycast is hitting floor this frame
	ground_check.enabled = true
	ground_check.force_raycast_update()
	var result: bool = false
	if ground_check.is_colliding():
		result = true
	else:
		result = false
	ground_check.enabled = false
	
	# Store this frame's result in an array
	rolling_ground_check_array.append(result)
	if rolling_ground_check_array.size() > rolling_ground_check_size:
		rolling_ground_check_array.pop_front()
	
	# If any of the last frames were on the ground, return true
	var is_grounded: bool = false
	for b in rolling_ground_check_array:
		if b == true:
			is_grounded = true
	print("On ground: ", is_grounded, " from ", rolling_ground_check_array.size(), " frames")
	
	return is_grounded
