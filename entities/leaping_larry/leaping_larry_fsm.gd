extends StateMachine

var mob: RbMob
var rand_gen: RandomNumberGenerator
var follow_target: Node3D = null
@onready var nav_agent: NavigationAgent3D = $"../NavigationAgent3D"

@onready var wander_timer: Timer = $"../Timers/WanderTimer" 
var wander_target: Vector3
var wander_stop_distance: float = 2.0
var wander_max_distance: float = 5.0
var wander_min_distance: float = 2.0

@onready var pause_timer: Timer = $"../Timers/PauseTimer"
var pause_time: float = 0.5
var pause_time_variance: float = 0.1

func _ready():
	rand_gen = RandomNumberGenerator.new()
	randomize()
	
	mob = get_parent()
	
	# Create states
	add_state("wander")
	add_state("pause")
	add_state("follow")
	call_deferred("set_state", states.wander)

func _state_logic(delta):
	mob.apply_gravity(delta)
	if state == states.wander:
		mob.direction = mob.global_position.direction_to(nav_agent.get_next_path_position()).normalized()
		
	if [states.pause].has(state):
		mob.direction = Vector3.ZERO
		
	if state == states.follow:
		nav_agent.target_position = follow_target.global_position
		mob.direction = mob.global_position.direction_to(nav_agent.get_next_path_position()).normalized()
		
	mob.accelerate(delta)
	mob.apply_movement()
	mob.prevent_y_axis_rotation()

func _get_transition(_delta):
	match state:
		states.wander:
			if mob.global_position.distance_to(wander_target) < wander_stop_distance \
				or wander_timer.time_left <= 0:
				return states.pause
		states.pause:
			if pause_timer.time_left <= 0:
				if follow_target != null:
					return states.follow
				else:
					return states.wander
		states.follow:
			if follow_target == null:
				return states.pause
	return null

func _enter_state(_new_state, _previous_state):
	state_changed.emit(states.keys()[_new_state])
	
	match state:
		states.wander:
			wander_timer.start()
			# Get a random x and z around the mob
			var wander_x_relative: float = rand_gen.randf_range(wander_min_distance, wander_max_distance)
			if rand_gen.randi_range(0, 1) == 1:
				wander_x_relative = -wander_x_relative
			var wander_z_relative: float = rand_gen.randf_range(wander_min_distance, wander_max_distance)
			if rand_gen.randi_range(0, 1) == 1:
				wander_z_relative = -wander_z_relative
			
			# Set the wander target position
			wander_target = mob.global_position + Vector3(wander_x_relative, 
				0, 
				wander_z_relative)
			nav_agent.target_position = wander_target
			
		states.pause:
			# Update the wait time with random variance, keeping within range
			pause_timer.wait_time = \
				clampf(rand_gen.randf_range(pause_timer.wait_time - pause_time_variance, 
					pause_timer.wait_time + pause_time_variance), \
					pause_time - pause_time_variance, pause_time + pause_time_variance)
			pause_timer.start()
			
		states.follow:
			mob.direction = mob.global_position.direction_to(follow_target.global_position)
			
		_:
			pass
	pass

func _exit_state(_old_state, _new_state):
	pass
