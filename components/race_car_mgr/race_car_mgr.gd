extends Node

@export var game_level: GameLevel

# Dict of players to checkpoint progress
var player_progress_dict = {}
var num_checkpoints: int

# Dict of players to laps completed
var player_laps_dict = {}
@export var num_laps = 3

var positions: Array

func _ready():
	if game_level == null:
		game_level = get_parent() as GameLevel
	
	call_deferred("initialize")


func initialize():
	# Populate player progress dict
	for player in game_level.players:
		player_progress_dict[player] = 0
		player_laps_dict[player] = 0
		positions.append(player)
	
	num_checkpoints = game_level.checkpoints.size()
	for cp in game_level.checkpoints:
		var checkpoint: Checkpoint = cp as Checkpoint
		checkpoint.checkpoint_entered.connect(on_checkpoint_entered)


func on_checkpoint_entered(cp: Node3D, body: Node3D):
	var checkpoint_index = game_level.checkpoints.find(cp)
	print("Checkpoint index: ", checkpoint_index)
	for player in player_progress_dict.keys():
		if player == body:
			print("one of our players entered checkpoint")
			if player_progress_dict[player] == checkpoint_index:
				player_progress_dict[player] = checkpoint_index + 1
				player.checkpoint_num = player_progress_dict[player] # TODO FIXME
				recalculate_positions()
				print("Incrementing this player's checkpoint progress: ", player)
				if player_progress_dict[player] > num_checkpoints:
					player_progress_dict[player] = 0
					player.checkpoint_num = player_progress_dict[player]
					recalculate_positions()
					print("Player completed a lap!")
					player_completed_lap(player)
			

func player_completed_lap(player: Node3D):
	player_laps_dict[player] = player_laps_dict[player] + 1
	player.lap = player_laps_dict[player]
	if player.has_node("RaceCarHud"):
		var player_hud: RaceCarHud = player.get_node("RaceCarHud")
		player_hud.lap_number.text = str(player_laps_dict[player])
	if player_laps_dict[player] > num_laps:
		print("Player has finished the race! ", player)


func recalculate_positions():
	if positions.size() <= 1:
		return
	for index in positions.size():
		if index == positions.size() - 1:
			for i in positions.size():
				var player = positions[i]
				if player.has_node("RaceCarHud"):
					var player_hud: RaceCarHud = player.get_node("RaceCarHud")
					player_hud.place_number.text = str(i + 1)
			return
		if positions[index].lap < positions[index + 1].lap:
			var infront = positions[index + 1]
			positions[index + 1] = positions[index]
			positions[index] = infront
			print("Car was passed by lap")
			recalculate_positions()
			
		if positions[index].lap == positions[index + 1].lap:
			if positions[index].checkpoint_num < positions[index + 1].checkpoint_num:
				var infront = positions[index + 1]
				positions[index + 1] = positions[index]
				positions[index] = infront
				print("Car was passed by checkpoint")
				recalculate_positions()
