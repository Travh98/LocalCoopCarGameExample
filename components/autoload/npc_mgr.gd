extends Node

## NpcMgr Autoload
## Manages performance related to NPCs
## Before you spawn NPCs, call this autoload and see if there is room
## If so, spawn npc and store reference, and then call the expensive updates from here infrequently

# Limit the number of NPCs in the world
const max_num_npcs: int = 20

# Limit the quality and frequency of logic calculations for performance reasons
# Lower numbers mean higher quality logic
var logic_lod: int = 0
var logic_lod_factor: float = 5

# Store references to known spawned Npcs
var spawned_npcs: Array
var npc_index: int = 0

var update_tick_timer: Timer

func _ready():
	print("NpcMgr loaded")
	
	update_tick_timer = Timer.new()
	update_tick_timer.one_shot = false
	update_tick_timer.wait_time = 1 + logic_lod * logic_lod_factor
	update_tick_timer.autostart = true
	update_tick_timer.timeout.connect(update_tick)
	get_tree().root.call_deferred("add_child", update_tick_timer)


func update_tick():
	if spawned_npcs.is_empty():
		return
	
	var npc = spawned_npcs[npc_index]
	if npc == null:
		print("NpcMgr missed update tick at index: ", npc_index)
		return
	else:
		print("NpcMgr found npc, running tick on: ", npc)
	
	# Run the expensive function on this npc
	npc.tick()
	
	# Optional: Run navigation agent repath on one NPC only at a time
	# Multiple navigation repaths at the same time is bad
	
	npc_index = npc_index + 1
	if npc_index > spawned_npcs.size():
		npc_index = 0


func on_request_spawn() -> bool:
	if spawned_npcs.size() < max_num_npcs:
		return true
	else:
		return false


func on_npc_spawned(npc: ChMob):
	spawned_npcs.append(npc)


func on_npc_despawned(npc: ChMob):
	var remove_index: int = spawned_npcs.find(npc)
	if remove_index < 0:
		return
	print("NpcMgr removing Npc: ", npc, " at array index: ", remove_index)
	spawned_npcs.remove_at(remove_index)
