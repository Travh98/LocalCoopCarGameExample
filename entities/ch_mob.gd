class_name ChMob
extends CharacterBody3D

## Base Mob class using CharacterBody3D
##
## All mobs will inherit from this, handles basic living being components

# Movement Variables
var gravity_multiplier := 3.0
var move_speed: float = 3
var walk_speed: float = 3
var sprint_speed: float = 8
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


func _ready():
	health_component.health_died.connect(on_death)
	if nav_agent != null:
		nav_agent.velocity_computed.connect(on_nav_velocity_computed)
	print("Creating class mob")


func apply_gravity(delta):
	velocity.y -= gravity * delta


func apply_movement():
	move_and_slide()


func apply_jump():
	velocity.y = jump_height


func apply_sprint(do_sprint: bool, delta: float):
	if do_sprint:
		move_speed = lerpf(move_speed, sprint_speed, delta)
	else:
		move_speed = lerpf(move_speed, walk_speed, delta)


func on_nav_velocity_computed(safe_velocity: Vector3):
	velocity = velocity.move_toward(safe_velocity, 0.25)


func apply_nav_agent_velocity():
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized()
	nav_agent.set_velocity(new_velocity * move_speed)


func accelerate(delta: float) -> void:
	# Using only the horizontal velocity, interpolate towards the input.
	var temp_vel := velocity
	temp_vel.y = 0
	
	var temp_accel: float
	var target: Vector3 = direction * move_speed
	
	if direction.dot(temp_vel) > 0:
		temp_accel = acceleration
	else:
		temp_accel = deceleration
	
	temp_vel = temp_vel.lerp(target, temp_accel * delta)
	
	velocity.x = temp_vel.x
	velocity.z = temp_vel.z


func on_death():
	global_position = Vector3.ZERO
	velocity = Vector3.ZERO
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
#	rotate(axis, angle_step)
	rotation.y = lerp(rotation.y, rotation.y + angle_step, angular_speed * angular_speed * delta)
#	rotation.y = lerp(rotation.y, abs(angle) * sign(angle), angular_speed * delta)
