extends StateMachine

var mob: ChMob
var input_controller: InputController

#@onready var anim_player: AnimationPlayer = $"../AnimationPlayer"
@onready var health_component: HealthComponent = $"../HealthComponent"
@onready var follow_camera: FollowCamera = $"../FollowCamera"
@onready var fp_camera: Camera3D = $"../FirstPersonCamera"
@onready var step_checker: StepChecker = $"../StepChecker"
@onready var tp_camera_pivot: Node3D = $"../CameraPivot"

@export var is_first_person: bool = true
var tp_sensitivity_x: float = 0.5
var tp_sensitivity_y: float = 0.5
var fp_sensitivity_x: float = 0.01
var fp_sensitivity_y: float = 0.01
var controller_tp_sensitivity_x: float = 1.5
var controller_tp_sensitivity_y: float = 1.5
var controller_fp_sensitivity_x: float = 0.1
var controller_fp_sensitivity_y: float = 0.1
var controller_min_axis_value: float = 0.1
var mouse_look_limit: float = 90.0
var input_axis: Vector2 = Vector2.ZERO

# Third Person Player will rotate in direction of movement unless input mouse movement is greater than this
const tp_rotate_camera_force_limit: float = 0.5


func _ready():
	mob = get_parent()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	health_component.health_died.connect(on_death)
	if is_first_person:
		fp_camera.make_current()
	else:
		follow_camera.make_current()
	
	# Create states
	add_state("walk")
	add_state("idle")
	call_deferred("set_state", states.walk)

func _state_logic(delta):
	handle_player_inputs()
	handle_move_input()
	
	if mob.is_on_floor():
		handle_jump()
		handle_sprint(delta)
	
	if !apply_step(delta):
		if not mob.is_on_floor():
			mob.apply_gravity(delta)
	
	# TODO Get that nice third person movement where they can walk around but if you need them to look you use the mouse
	if !is_first_person:
		handle_mob_and_camera_rotation(delta)
	
	if !input_controller.is_keyboard:
		handle_controller_camera_rotation()
	
	mob.accelerate(delta)
	mob.apply_movement()

func _get_transition(_delta):
	match state:
		_:
			pass
	return null

func _enter_state(_new_state, _previous_state):
	state_changed.emit(states.keys()[_new_state])
	
	match state:
		_:
			pass
	pass

func _exit_state(_old_state, _new_state):
	pass


func _input(event):
	if event is InputEventMouseMotion:
		if !is_first_person:
			if abs(event.relative.x) > tp_rotate_camera_force_limit:
				tp_camera_pivot.rotate_y(deg_to_rad(-event.relative.x) * tp_sensitivity_x)
		else:
			# Mouse look (only if the mouse is captured).
			if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				# rotation of character on y axis
				mob.rotate_y(-event.relative.x * fp_sensitivity_y)
				# Vertical mouse look
				fp_camera.rotation.x = clamp(fp_camera.rotation.x - event.relative.y * fp_sensitivity_x, -deg_to_rad(mouse_look_limit), deg_to_rad(mouse_look_limit))


func handle_controller_camera_rotation():
	var look_relative: Vector2 = input_controller.look_relative_vector
	if !is_first_person:
		if abs(look_relative.x) > tp_rotate_camera_force_limit:
			tp_camera_pivot.rotate_y(deg_to_rad(-look_relative.x) * controller_tp_sensitivity_x)
	else:
#		print("Look Relative: ", look_relative)
		# rotation of character on y axis
		if abs(look_relative.x) > controller_min_axis_value:
			mob.rotate_y(-look_relative.x * controller_fp_sensitivity_y)
		# Vertical look
		if abs(look_relative.y) > controller_min_axis_value:
			fp_camera.rotation.x = clamp(fp_camera.rotation.x - look_relative.y * controller_fp_sensitivity_x, -deg_to_rad(mouse_look_limit), deg_to_rad(mouse_look_limit))


func handle_player_inputs():
	if input_controller.is_keyboard:
		# Keyboard players need to handle the mouse
		if input_controller.is_action_just_pressed("left_click"):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if input_controller.is_action_just_pressed("escape"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if input_controller.is_action_just_pressed("change_perspective"):
		if is_first_person:
			follow_camera.current = true
			fp_camera.current = false
			is_first_person = false
		else:
			fp_camera.current = true
			follow_camera.current = false
			is_first_person = true


func handle_move_input():
#	input_axis = input_controller.get_vector(&"move_backward", &"move_forward",
#				&"move_left", &"move_right")
	input_axis = input_controller.move_vector
	if is_first_person:
		mob.direction = -mob.global_transform.basis.z * input_axis.x \
		+ mob.global_transform.basis.x * input_axis.y 
	else:
		var forward: Vector3 = -follow_camera.global_transform.basis.z.normalized()
		mob.direction = -forward * -input_axis.x + forward.cross(Vector3.UP) * input_axis.y


func handle_mob_and_camera_rotation(delta: float):
	# Setting global pos because pivot is Top Level
	tp_camera_pivot.global_position = mob.global_position + Vector3.UP
	
	# If player is trying to move
	if input_axis != Vector2.ZERO:
		# Move camera to right behind player
#		tp_camera_pivot.rotation_degrees.y = 0
		# Rotate the player relative to the camera
		# TODO Boy this is confusing!
		mob.rotate_towards_motion_no_y(delta)


func handle_sprint(delta: float):
	if input_controller.is_action_pressed("sprint"):
		mob.move_speed = lerpf(mob.move_speed, mob.sprint_speed, mob.move_speed * delta)
	else:
		mob.move_speed = lerpf(mob.move_speed, mob.walk_speed, mob.move_speed * delta)


func handle_jump():
	if input_controller != null:
		if input_controller.is_buffered_action_just_pressed("jump"):
			mob.apply_jump()
#	if Input.is_action_just_pressed("jump"):
#		mob.apply_jump()


func apply_step(delta: float) -> bool:
	# Get desired direction from input
#	var input_axis: Vector2 = Input.get_vector(&"move_backward", &"move_forward",
#			&"move_left", &"move_right")
#	var forward: Vector3 = -mob.global_transform.basis.z.normalized()
#	var desired_direction: Vector3 = forward * input_axis.x + forward.cross(Vector3.UP) * input_axis.y
	
	var step_to_pos: Vector3 = step_checker.can_step(mob.direction, delta)
	var desired_y_pos: float = 0.0
	if step_to_pos != Vector3.ZERO:
		desired_y_pos = step_to_pos.y - mob.global_position.y
		if desired_y_pos > 0 and desired_y_pos < step_checker.step_height:
			desired_y_pos = step_checker.step_height # Setting desired height to be higher than the step, so its easy to clear the steps when stepping
			# TODO do we really need step_height if we have the wall_check?
	else:
		desired_y_pos = 0
	
	# Return true if we have stepped
	if desired_y_pos <= 0:
		# We will descend using gravity
		return false
	else:
		# Hard set the mob's y velocity
		mob.velocity.y = desired_y_pos * mob.move_speed * 3
		return true


func on_death():
	# Reset the player
	mob.global_position = Vector3.ZERO
	mob.velocity = Vector3.ZERO
	health_component.full_heal()


func _set_input_controller(ctrl: InputController):
	print("Setting input controller")
	input_controller = ctrl
