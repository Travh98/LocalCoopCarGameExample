extends StateMachine

var mob: ChMob

#@onready var anim_player: AnimationPlayer = $"../AnimationPlayer"
@onready var health_component: HealthComponent = $"../HealthComponent"
@onready var follow_camera: FollowCamera = $"../FollowCamera"
@onready var first_person_camera: Camera3D = $"../FirstPersonCamera"
@onready var step_checker: StepChecker = $"../StepChecker"

@export var is_first_person: bool = false
var sensitivity_x: float = 0.5
var sensitivity_y: float = 0.5

# Third Person Player will rotate in direction of movement unless input mouse movement is greater than this
const third_person_rotate_camera_force_limit: float = 5.0


func _ready():
	mob = get_parent()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	health_component.health_died.connect(on_death)
	
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
#	if !is_first_person:
#		mob.rotate_towards_motion_no_y(delta)
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
			if abs(event.relative.x) > third_person_rotate_camera_force_limit:
				mob.rotate_y(deg_to_rad(-event.relative.x) * sensitivity_x)


func handle_player_inputs():
	if Input.is_action_just_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.is_action_just_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_action_just_pressed("change_perspective"):
		if is_first_person:
			follow_camera.current = true
			first_person_camera.current = false
			is_first_person = false
		else:
			first_person_camera.current = true
			follow_camera.current = false
			is_first_person = true


func handle_move_input():
	if is_first_person:
		pass
	else:
		var forward: Vector3 = -follow_camera.global_transform.basis.z.normalized()
		var input_axis = Input.get_vector(&"move_backward", &"move_forward",
				&"move_left", &"move_right")
		
		mob.direction = -forward * -input_axis.x + forward.cross(Vector3.UP) * input_axis.y


func handle_sprint(delta: float):
	if Input.is_action_pressed("sprint"):
		mob.move_speed = lerpf(mob.move_speed, mob.sprint_speed, mob.move_speed * delta)
	else:
		mob.move_speed = lerpf(mob.move_speed, mob.walk_speed, mob.move_speed * delta)


func handle_jump():
	if Input.is_action_just_pressed("jump"):
		mob.apply_jump()


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
