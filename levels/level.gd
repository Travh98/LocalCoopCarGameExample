extends Node3D


@onready var player_spawn_spots: Node3D = $PlayerSpawnSpots

func _ready():
	
	# Spawn players on level start
	var PlayerScene = GameManager.PlayerScene
	var InputControllerScene: PackedScene = GameManager.InputControllerScene
	
	var spawn_spots = player_spawn_spots.get_children()
	for device_id in GameManager.players.keys():
		var player: Player = PlayerScene.instantiate()
		add_child(player)
		
		var player_info: GameManager.PlayerInfo = GameManager.players[device_id]
		player.global_position = spawn_spots[player_info.device_id].global_position
		player.global_rotation = spawn_spots[player_info.device_id].global_rotation
		
		# Create input controller and attach to player
		
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("quick_quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("reset_level"):
		get_tree().reload_current_scene()
	if Input.is_action_pressed("fullscreen"):
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
