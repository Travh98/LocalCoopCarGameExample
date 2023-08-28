extends Control

@onready var start_button: Button = $MarginContainer/VBoxContainer/HBoxContainer2/StartButton
@onready var controller_selection_panels = $MarginContainer/VBoxContainer/ControllerSelectionPanels
var ControllerSelectionPanel = preload("res://ui/controller_selection_panel.tscn")

# Dictionary of device ids to controller selection panels
var controller_panels = {}

var next_scene_path: String = "res://levels/testing/test_level_1.tscn"

func _ready():
	Input.joy_connection_changed.connect(on_joy_connection_changed)
	
	start_button.pressed.connect(on_start_pressed)
	
	for device_id in Input.get_connected_joypads():
		print("Device: ", device_id, " ", Input.get_joy_name(device_id), " ", Input.get_joy_guid(device_id))
		on_joy_connection_changed(device_id, true)


func _input(event):
	if event is InputEventJoypadButton:
		if Input.is_action_just_pressed("jump"):
			if event.is_pressed():
				if controller_panels[event.device] != null:
					var ctrl_panel: ControllerSelectionPanel = controller_panels[event.device]
					if ctrl_panel != null:
						ctrl_panel.is_ready = true


func on_joy_connection_changed(device_id: int, connected: bool):
	if connected:
		var ctrl_panel: ControllerSelectionPanel = ControllerSelectionPanel.instantiate()
		controller_selection_panels.add_child(ctrl_panel)
		ctrl_panel.device_name_label.text = Input.get_joy_name(device_id) + " Device ID: " + str(device_id)
		controller_panels[device_id] = ctrl_panel
	else:
		if controller_panels[device_id] != null:
			var ctrl_panel: ControllerSelectionPanel = controller_panels[device_id]
			if ctrl_panel != null:
				ctrl_panel.queue_free()


func on_start_pressed():
	for id in controller_panels:
		if controller_panels[id].is_ready:
			GameManager.register_player(id, Color.ORANGE_RED, "Player" + str(id))
	
	GameManager.change_level(next_scene_path)
	queue_free()
