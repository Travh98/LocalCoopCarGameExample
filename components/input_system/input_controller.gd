class_name InputController
extends Node


# There will be only one keyboard per PC
var is_keyboard: bool = false
# Which controller this input is from
var device_id: int = -1

var min_controller_value: float = 0.1

# Dict of action strings to number of frames left
var buffered_inputs = {}
var buffer_frames: int = 5

# Dict of action strings to boolean of is_held_down
var held_inputs = {}

# Vector that is updated by the movement joystick
var move_vector: Vector2
# Vector that is updated by the relative movement of the camera joystick
var look_relative_vector: Vector2


func _ready():
	for action_str in InputMap.get_actions():
		held_inputs[action_str] = false
		buffered_inputs[action_str] = 0


func _input(event):
	# Update every time there is input
	
	if event is InputEventJoypadButton:
		if is_keyboard == true:
			return
		
		if event.device != device_id:
			return
		
		for action_str in InputMap.get_actions():
			if Input.is_action_just_pressed(action_str):
				buffered_inputs[action_str] = buffer_frames
				held_inputs[action_str] = true
			if Input.is_action_just_released(action_str):
				held_inputs[action_str] = false
	
#	if event is InputEventJoypadMotion:
#		if is_keyboard == true:
#			return
#
#		if event.device != device_id:
#			return
#
#		move_vector = Input.get_vector(&"move_backward", &"move_forward",
#			&"move_left", &"move_right")
	
	if event is InputEventMouseButton:
		if is_keyboard == false:
			return


func _process(_delta):
	# Count down the number of buffered frames
	for action_str in buffered_inputs.keys():
		if buffered_inputs[action_str] > 0:
			# Subtract 1 instead of delta because this function is called every frame
			buffered_inputs[action_str] = buffered_inputs[action_str] - 1
#			print("Action Str: ", action_str, " has frames left: ", buffered_inputs[action_str])


func _physics_process(_delta):
	# Update look vectors
	look_relative_vector.x = Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_X)
	look_relative_vector.y = Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_Y)
	
	move_vector.x = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X)
	if abs(move_vector.x) < min_controller_value:
		move_vector.x = 0
	move_vector.y = -Input.get_joy_axis(device_id, JOY_AXIS_LEFT_Y)
	if abs(move_vector.y) < min_controller_value:
		move_vector.y = 0
	


func is_buffered_action_just_pressed(action_str: String) -> bool:
	# Look in the buffered_inputs dictionary and see how many frames are left
	# for the input action string
	if !buffered_inputs.has(action_str):
		return false
	
	var frames_left: int =  buffered_inputs[action_str]
	if frames_left > 0:
		return true
	else:
		return false


func is_action_just_pressed(action_str: String) -> bool:
	# I need to be able to filter inputs based on device_id to support multiple joysticks
	# To handle action just pressed, I would create another dictionary for just_pressed_actions
	# However that would basically just be another buffer, so for now everything is buffered
	return is_buffered_action_just_pressed(action_str)


func is_action_pressed(action_str: String) -> bool:
	# Return the stored value in held_inputs
	if !held_inputs.has(action_str):
		return false
	
	return held_inputs[action_str]


#func get_action_strength(action: StringName, exact_match: bool = false) -> float:
#	Input.get_joy_axis()
