extends Node

signal signal_jump

# There will be only one keyboard per PC
var is_keyboard: bool = false

var device_id: int = -1


func _input(event):
	if event is InputEventJoypadButton:
		if is_keyboard == true:
			return
		
		if Input.is_action_just_pressed("jump"):
			if event.device == device_id:
				print("Device #", device_id, " registered a jump!")
				signal_jump.emit()
	
	if event is InputEventMouseButton:
		if is_keyboard == false:
			return
