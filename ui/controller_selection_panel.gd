class_name ControllerSelectionPanel
extends PanelContainer


@onready var device_name_label: Label = $VBoxContainer/DeviceNameLabel
@onready var controller_status_label: Label = $VBoxContainer/ControllerStatusLabel
var is_ready: bool = false: set = _set_is_ready


func _set_is_ready(ready: bool):
	is_ready = ready
	if ready:
		controller_status_label.text = "READY"
	else:
		controller_status_label.text = "PRESS A TO JOIN"
