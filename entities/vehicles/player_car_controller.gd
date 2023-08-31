extends Node

## Basically a state machine to control the car

var car: VehicleBody3D
var input_controller: InputController
var last_checkpoint: Node3D = null

var max_steering_amount: float = 0.2
var max_engine_force: int = 1200
var brake_factor: int = 50
var acceleration: int = 1600
var boost_force = 3000
var respawn_boost: float = 10
var used_rocket_charges: int = 0
var max_rocket_charges: int = 1

@onready var upright_timer: Timer = $"../UprightVehicleTimer"
@onready var camera_spring_arm: SpringArm3D = $"../SpringArm3D"
@onready var health_component: HealthComponent = $"../HealthComponent"
@onready var dust_bubble_particles: GPUParticles3D = $"../DustBubbleParticles"
@onready var boost_cooldown_timer: Timer = $"../BoostCooldownTimer"
@onready var rocket_cooldown_timer: Timer = $"../RocketCooldownTimer"
@onready var air_trick_delay_timer: Timer = $"../AirTrickDelayTimer"
@onready var is_grounded_raycast: RayCast3D = $"../IsGroundedRayCast"

func _ready():
	upright_timer.timeout.connect(reset_upright)
	health_component.health_died.connect(on_death)
	
	car = get_parent()


func _process(_delta):
	if input_controller == null:
		if car.has_node("InputController"):
			input_controller = car.get_node("InputController") as InputController


func _physics_process(delta):
	if input_controller == null:
		return
	
	var gas_pedal: float = Input.get_joy_axis(input_controller.device_id, JOY_AXIS_TRIGGER_RIGHT)
	var brake_pedal: float = Input.get_joy_axis(input_controller.device_id, JOY_AXIS_TRIGGER_LEFT)
	
	car.steering = lerp(car.steering, -input_controller.move_vector.x * max_steering_amount, 8 * delta)
	
	# Brake the car if slightly braking
	if brake_pedal > 0.1 and brake_pedal < 0.9:
		car.brake = brake_pedal * brake_pedal * brake_factor
	else:
		# Release the brake
		car.brake = 0
	# If fully braking, start driving backwards
	if brake_pedal >= 0.9:
		car.brake = 0
		car.engine_force = clamp(-brake_pedal * acceleration, -max_engine_force, 0)
	else:
		# Drive forwards
		car.engine_force = clamp(gas_pedal * acceleration, 0, max_engine_force)
	
	handle_particles()
	
	try_uprighting_car()
	rotate_camera_arm(delta)
	mid_air_rotations(delta)
	
	handle_boost_powers()
	
#	if Input.is_action_pressed("look_behind"):
#		camera_spring_arm.rotation_degrees.y = 180
#	else:
#		camera_spring_arm.rotation_degrees.y = 0


func reset_upright():
	if abs(rad_to_deg(car.rotation.z)) >= 85:
		car.global_position = car.global_position + Vector3.UP * 0.25
		car.rotation.z = 0.0
		car.angular_velocity = Vector3.ZERO
		car.linear_velocity = Vector3.ZERO


func on_death():
	# Respawn at last checkpoint, facing the right direction
	if last_checkpoint != null:
		car.global_position = last_checkpoint.global_position
		car.global_rotation = last_checkpoint.global_rotation
	else:
		car.global_position = Vector3.ZERO
		car.global_rotation = Vector3.ZERO
	car.angular_velocity = Vector3.ZERO
	# Boost the player so they can catch up
	car.linear_velocity = -car.global_transform.basis.z * respawn_boost


func rotate_camera_arm(delta: float):
	# Reset camera if not trying to look
	if abs(input_controller.look_relative_vector.x) <= 0.2:
		camera_spring_arm.rotation.y = 0
	
	# Try rotating camera to the right, in order to look left
	if camera_spring_arm.rotation.y < deg_to_rad(45) and input_controller.look_relative_vector.x < 0:
		camera_spring_arm.rotation = lerp(camera_spring_arm.rotation,
			camera_spring_arm.rotation + Vector3(0, -input_controller.look_relative_vector.x, 0), 
			8 * delta)
	
	# Try rotating the camera to the left, in order to look right
	if camera_spring_arm.rotation.y > deg_to_rad(-45) and input_controller.look_relative_vector.x > 0:
		camera_spring_arm.rotation = lerp(camera_spring_arm.rotation,
			camera_spring_arm.rotation + Vector3(0, -input_controller.look_relative_vector.x, 0), 
			8 * delta)


func jump_car():
	car.apply_central_impulse(-car.global_transform.basis.z * boost_force + car.global_transform.basis.y * boost_force)


func rocket_car_forward():
	car.angular_velocity = car.angular_velocity / 2
	car.linear_velocity = car.linear_velocity / 2
	car.apply_central_impulse(-car.global_transform.basis.z * boost_force * 2)


func try_uprighting_car():
	# If not upright and not counting down the upright timer, start counting
	# This way we can do flips and we will only reset upright if actually stuck
	if abs(rad_to_deg(car.rotation.z)) >= 85:
		if upright_timer.time_left <= 0:
			upright_timer.start()
	else:
		# Stop the upright timer if we upright ourselves
		upright_timer.stop()


func handle_particles():
	if abs(car.engine_force) > 100.0:
		dust_bubble_particles.emitting = true
	else:
		dust_bubble_particles.emitting = false


func mid_air_rotations(delta: float):
	# If on the ground, start the delay of the air tricks
	if is_grounded_raycast.is_colliding():
		air_trick_delay_timer.start()
	
	# Allow the car to tilt while in the air
	# If off the ground and we have delayed air tricks long enough
	if !is_grounded_raycast.is_colliding() and air_trick_delay_timer.time_left <= 0:
		car.rotation.y = lerpf(car.rotation.y, car.rotation.y + -input_controller.move_vector.x, 4 * delta)
		car.rotation.x = lerpf(car.rotation.x, car.rotation.x + -input_controller.move_vector.y, 1 * delta)
		
		# This generally keeps our wheels pointing downwards, making landing easier
		car.rotation.z = lerpf(car.rotation.z, 0, 2 * delta)
	
	
func handle_boost_powers():
	if input_controller.is_action_just_pressed("jump"):
		if is_grounded_raycast.is_colliding():
			if boost_cooldown_timer.time_left <= 0:
				boost_cooldown_timer.start()
				rocket_cooldown_timer.start() # Also cooldown the rockets
				jump_car()
		else:
			if used_rocket_charges < max_rocket_charges and rocket_cooldown_timer.time_left <= 0:
				rocket_car_forward()
				used_rocket_charges = used_rocket_charges + 1
				rocket_cooldown_timer.start()
	if is_grounded_raycast.is_colliding():
		used_rocket_charges = 0
