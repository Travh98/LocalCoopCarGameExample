extends Node

# By default user:// is %APPDATA%\Godot\app_userdata\[project_name] on windows
const save_file = "user://saved_settings.save"

var game_data = {}

func _ready():
	load_data()


func load_data():
	if not FileAccess.file_exists(save_file):
		# Create default settings
		game_data = {
			"fullscreen_on": false,
			"vsync_on": false,
			"display_fps": false,
			"max_fps": 0,
			"bloom_on": false,
			"brightness": 1,
			"master_vol": -10,
			"music_vol": -10,
			"sfx_vol": -10,
			"fov": 70,
			"mouse_sens": 0.1,
		}
		save_data()
	
	var file = FileAccess.open(save_file, FileAccess.READ)
	game_data = file.get_var()
	file.close()


func save_data():
	var file = FileAccess.open(save_file, FileAccess.WRITE)
	file.store_var(game_data)
	file.close()
