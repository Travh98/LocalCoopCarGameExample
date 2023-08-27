class_name InputController
extends Node


# There will be only one keyboard per PC
var is_keyboard: bool = false
# Which controller this input is from
var device_id: int = -1

# Map of action strings to number of frames left
var buffered_inputs = {}
var buffer_frames: int = 100

func _input(event):
	if event is InputEventJoypadButton:
		if is_keyboard == true:
			return
		
		if Input.is_action_just_pressed("jump"):
			if event.device == device_id:
				print("Device #", device_id, " registered a jump!")
				# Set the just jumped flag
				buffered_inputs["jump"] = buffer_frames
	
	if event is InputEventMouseButton:
		if is_keyboard == false:
			return


func _process(delta):
	# Count down the number of buffered frames
	for action_str in buffered_inputs.keys():
		if buffered_inputs[action_str] > 0:
			buffered_inputs[action_str] = buffered_inputs[action_str] - delta


func is_buffered_action_just_pressed(action_str: String) -> bool:
	if buffered_inputs[action_str] == null:
		return false
	
	# See how many frames are left in this buffered input
	var frames_left: int =  buffered_inputs[action_str]
	if frames_left > 0:
		return true
	else:
		return false
