extends Node3D

@onready var split_screen_grid: SplitScreenGrid = $SplitScreenGrid
@onready var player_spawn_spots: Node3D = $PlayerSpawnSpots
@onready var PlayerScene: PackedScene = preload("res://entities/vehicles/mustang.tscn")

func _ready():
	# Spawn players on level start
	
	# We could get players from the GameManager but this level will be driving so use specific playerscene
#	var PlayerScene = GameManager.PlayerScene
	var InputControllerScene: PackedScene = GameManager.InputControllerScene
	
	var spawn_spots = player_spawn_spots.get_children()
	for device_id in GameManager.players.keys():
		var player: Node3D = PlayerScene.instantiate() as Node3D
		if player == null:
			return
		
		var split_screen_container: SplitScreenContainer = split_screen_grid.add_player_view()
		split_screen_container.sub_viewport.add_child(player)
		
		var player_info: GameManager.PlayerInfo = GameManager.players[device_id]
		player.global_position = spawn_spots[player_info.device_id].global_position
		player.global_rotation = spawn_spots[player_info.device_id].global_rotation
		
		# Create input controller and attach to player
		var input_controller: InputController = InputControllerScene.instantiate() as InputController
		player.add_child(input_controller)
		if player.has_node("StateMachine"):
			player.get_node("StateMachine").input_controller = input_controller
			
		input_controller.device_id = player_info.device_id
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("quick_quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("reset_level"):
		get_tree().reload_current_scene()
	if Input.is_action_pressed("fullscreen"):
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
