extends Node

## Game Manager

class PlayerInfo:
	var name: String
	var device_id: int = -1
	var color: Color = Color.RED

# Dictionary of device_id to PlayerInfos
var players = {}
var PlayerScene: PackedScene = preload("res://entities/player/player.tscn")
var InputControllerScene: PackedScene = preload("res://components/input_system/input_controller.tscn")

var current_level_node_name: String

func _ready():
	print("GameManager loaded")


func register_player(device_id: int, color: Color, name: String):
	var player_info: PlayerInfo = PlayerInfo.new()
	player_info.name = name
	player_info.device_id = device_id
	player_info.color = color
	print("Created player info in GameManager: ", device_id, " ", name)
	players[device_id] = player_info


func change_level(level_path: String):
	var level = get_tree().root.get_node(current_level_node_name)
	if level != null:
		get_tree().root.remove_child(level)
	
	var next_level_resource: PackedScene = load(level_path)
	var next_level = next_level_resource.instantiate()
	print("Changing level from: ", current_level_node_name, " to: ", next_level.name)
	current_level_node_name = next_level.name
	get_tree().root.add_child(next_level)
	
	
