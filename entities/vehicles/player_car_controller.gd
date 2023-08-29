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
	
	car.steering = lerp(car.steering, -input_controller.move_vector.y * 0.2, 8 * delta)
#	var accel = input_controller.move_vector.x * 400
#	car.brake = Input.get_action_strength("brake") * 10
	car.engine_force = clamp(input_controller.move_vector.x * 1600, -400, 400)
	
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
	if last_checkpoint != null:
		car.global_position = last_checkpoint.global_position
		car.global_rotation = last_checkpoint.global_rotation
	else:
		car.global_position = Vector3.ZERO
		car.global_rotation = Vector3.ZERO
	car.angular_velocity = Vector3.ZERO
	car.linear_velocity = Vector3.ZERO
