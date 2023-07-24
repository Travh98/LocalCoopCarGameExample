extends StateMachine

var mob: Mob
var rand_gen: RandomNumberGenerator
var follow_target: Node3D = null

var wander_target: Vector3
var wander_stop_distance: float = 2.0
var wander_max_distance: float = 5.0
var wander_min_distance: float = 2.0

var pause_timer: Timer
var pause_time: float = 0.5
var pause_time_variance: float = 0.1

func _ready():
	rand_gen = RandomNumberGenerator.new()
	randomize()
	
	pause_timer = Timer.new()
	pause_timer.one_shot = true
	pause_timer.wait_time = pause_time
	add_child(pause_timer)
	
	mob = get_parent()
	
	# Create states
	add_state("wander")
	add_state("pause")
	add_state("follow")
	call_deferred("set_state", states.wander)

func _state_logic(delta):
	mob.apply_gravity(delta)
	if state == states.wander:
		pass
	if [states.pause].has(state):
		mob.direction = Vector3.ZERO

	mob.accelerate(delta)
	mob.apply_movement()

func _get_transition(_delta):
	match state:
		states.wander:
			if mob.global_position.distance_to(wander_target) < wander_stop_distance:
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
			# Get a random x and z around the frog
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
			mob.direction = mob.global_position.direction_to(wander_target).normalized()
			if mob.is_on_floor():
				mob.apply_jump()
			pass
		states.pause:
			pause_timer.wait_time = rand_gen.randf_range(pause_time - pause_time_variance, pause_time + pause_time_variance)
			pause_timer.start()
			pass
		states.follow:
			mob.direction = mob.global_position.direction_to(follow_target.global_position)
		_:
			pass
	pass

func _exit_state(_old_state, _new_state):
	pass
