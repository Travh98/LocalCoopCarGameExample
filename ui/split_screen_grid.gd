class_name SplitScreenGrid
extends Control


@onready var top_screen_row: Control = $VBoxContainer/TopScreenRow
@onready var bottom_screen_row: Control = $VBoxContainer/BottomScreenRow
@onready var SplitScreenContainerScene: PackedScene = preload("res://ui/split_screen_container.tscn")
var num_players: int = 0
var split_screen_containers = {}

func add_player_view() -> SplitScreenContainer:
	var split_screen_container: SplitScreenContainer = SplitScreenContainerScene.instantiate() as SplitScreenContainer
	if split_screen_container == null:
		return null
	
	# Put the viewport container in the appropriate spot for split screen based on num of existing views
	match num_players:
		0:
			bottom_screen_row.set_v_size_flags(Control.SIZE_FILL)
			top_screen_row.add_child(split_screen_container)
		1:
			# Hide the bottom row
			bottom_screen_row.set_v_size_flags(Control.SIZE_FILL)
			top_screen_row.add_child(split_screen_container)
		2:
			# Expand the bottom row so its equal in height to the top
			bottom_screen_row.set_v_size_flags(top_screen_row.get_v_size_flags())
			bottom_screen_row.add_child(split_screen_container)
		3:
			bottom_screen_row.add_child(split_screen_container)
		4:
			top_screen_row.add_child(split_screen_container)
		5:
			bottom_screen_row.add_child(split_screen_container)
		6:
			top_screen_row.add_child(split_screen_container)
		7:
			bottom_screen_row.add_child(split_screen_container)
		_:
			top_screen_row.add_child(split_screen_container)
	
	# Store to dict (TODO support adding removing players mid game)
	split_screen_containers[num_players] = split_screen_container
	
	num_players = num_players + 1
	
	# Return the container in case anyone wants to add a child to it (like the Player camera)
	return split_screen_container
