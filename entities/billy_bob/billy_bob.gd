extends Mob

@onready var dev_info_tag: DevInfoTag = $DevInfoTag3D/SubViewport/DevInfoTag

func _ready():
	dev_info_tag.set_name_label(name)
	print("Creating class billy bob")
	super() # Call base class ready
