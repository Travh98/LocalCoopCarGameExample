class_name Player
extends ChMob

@onready var dev_info_tag: DevInfoTag = $DevInfoTag3D/SubViewport/DevInfoTag
@onready var state_machine: StateMachine = $StateMachine

func _ready():
	dev_info_tag.set_name_label(name)
	state_machine.state_changed.connect(dev_info_tag.set_state_label)
	super() # Call base class ready
