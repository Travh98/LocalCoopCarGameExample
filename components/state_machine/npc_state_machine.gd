class_name NpcStateMachine
extends StateMachine

## The brains / controller part of the NPC
## NpcStateMachine attaches as a component to a Mob and controls the Mob
## Registers with NpcMgr and expensive ticks are triggered from NpcMgr

@onready var change_state_timer: Timer = $ChangeStateTimer

func _ready():
	if NpcMgr != null:
		var can_spawn: bool = NpcMgr.on_request_spawn()
		if can_spawn:
			# Assuming parent is the Mob
			NpcMgr.call_deferred("on_npc_spawned", get_parent()) 
		else:
			print("Warning, illegal NpcStateMachine spawn on: ", get_parent())
	else:
		print("NpcMgr is null, ", get_parent(), " cannot find NpcMgr")


func update_tick():
	pass # Virtual function
