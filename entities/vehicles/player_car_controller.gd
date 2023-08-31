extends Node

## Basically a state machine to control the car

var car: VehicleBody3D
var input_controller: InputController
var last_checkpoint: Node3D = null

var max_rpm = 500 
var max_torque = 500

@onready var upright_timer: Timer = $"../UprightVehicleTimer"
@onready var camera_spring_arm: SpringArm3D = $"../SpringArm3D"
@onready var health_component: HealthComponent = $"../HealthComponent"
@onready var dust_bubble_particles: GPUParticles3D = $"../DustBubbleParticles"

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
	car.steering = lerp(car.steering, -input_controller.move_vector.x * 0.2, 8 * delta)
	if brake_pedal > 0 and brake_pedal < 0.5:
		car.brake = brake_pedal * 10
	if brake_pedal >= 0.5:
		car.engine_force = clamp(-brake_pedal * 1600, -600, 0)
	else:
		car.engine_force = clamp(gas_pedal * 1600, 0, 600)
	
	if abs(car.engine_force) > 100.0:
		dust_bubble_particles.emitting = true
	else:
		dust_bubble_particles.emitting = false
	
	# If not upright and not counting down the upright timer, start counting
	# This way we can do flips and we will only reset upright if actually stuck
	if abs(rad_to_deg(car.rotation.z)) >= 85:
		if upright_timer.time_left <= 0:
			upright_timer.start()
	else:
		# Stop the upright timer if we upright ourselves
		upright_timer.stop()
	
	if camera_spring_arm.rotation.y < deg_to_rad(45) and input_controller.look_relative_vector.x > 0:
		camera_spring_arm.rotation = lerp(camera_spring_arm.rotation,
			camera_spring_arm.rotation + Vector3(0, input_controller.look_relative_vector.x, 0), 
			8 * delta)
	if camera_spring_arm.rotation.y > deg_to_rad(-45) and input_controller.look_relative_vector.x < 0:
		camera_spring_arm.rotation = lerp(camera_spring_arm.rotation,
			camera_spring_arm.rotation + Vector3(0, input_controller.look_relative_vector.x, 0), 
			8 * delta)
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
	print("Player died")
	if last_checkpoint != null:
		car.global_position = last_checkpoint.global_position
		car.global_rotation = last_checkpoint.global_rotation
	else:
		car.global_position = Vector3.ZERO
		car.global_rotation = Vector3.ZERO
	car.angular_velocity = Vector3.ZERO
	car.linear_velocity = Vector3.ZERO
