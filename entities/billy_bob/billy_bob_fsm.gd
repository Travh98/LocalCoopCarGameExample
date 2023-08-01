extends StateMachine

var mob: ChMob
var rand_gen: RandomNumberGenerator
var follow_target: Node3D = null
@onready var nav_agent: NavigationAgent3D = $"../NavigationAgent3D"
@onready var detection_area: Area3D = $"../DetectionArea"
@onready var bump_area: Area3D = $"../BumpArea"
var item_target: Node3D = null
@onready var step_checker: StepChecker = $"../StepChecker"

@onready var wander_timer: Timer = $"../Timers/WanderTimer" 
var wander_target: Vector3
var wander_stop_distance: float = 2.0
var wander_max_distance: float = 5.0
var wander_min_distance: float = 2.0

@onready var pause_timer: Timer = $"../Timers/PauseTimer"
var pause_time: float = 0.5
var pause_time_variance: float = 0.1

@onready var scan_for_items_timer: Timer = $"../Timers/ScanForItemsTimer"

func _ready():
	rand_gen = RandomNumberGenerator.new()
	rand_gen.randomize()
	
	bump_area.body_entered.connect(on_bump_area_body_entered)
	
	mob = get_parent()
	
	# Create states
	add_state("wander")
	add_state("pause")
	add_state("follow")
	add_state("move_to_item")
	call_deferred("set_state", states.wander)


func _state_logic(delta):
	if state == states.wander:
		mob.direction = mob.global_position.direction_to(nav_agent.get_next_path_position()).normalized()
		
	if [states.pause].has(state):
		mob.direction = Vector3.ZERO
		
	if state == states.follow:
		nav_agent.target_position = follow_target.global_position
		mob.direction = mob.global_position.direction_to(nav_agent.get_next_path_position()).normalized()
	
	if state == states.move_to_item:
		if item_target != null:
			nav_agent.target_position = item_target.global_position
			mob.direction = mob.global_position.direction_to(nav_agent.get_next_path_position()).normalized()
	
	mob.rotate_towards_motion_no_y(delta)
	mob.accelerate(delta)
	mob.apply_movement()
	handle_step(delta)
	
	# Scan for items every x seconds if we don't have a item target
	if item_target == null:
		if scan_for_items_timer.time_left <= 0:
			scan_for_item_target()
			scan_for_items_timer.start()


func _get_transition(_delta):
	match state:
		states.wander:
			if mob.global_position.distance_to(wander_target) < wander_stop_distance \
				or wander_timer.time_left <= 0:
				return states.pause
		states.pause:
			if pause_timer.time_left <= 0:
				if item_target != null:
					return states.move_to_item
				if follow_target != null:
					return states.follow
				else:
					return states.wander
		states.follow:
			if follow_target == null:
				return states.pause
		states.move_to_item:
			if item_target == null:
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
			pass
		states.move_to_item:
			pass
		_:
			pass
	pass


func _exit_state(_old_state, _new_state):
	pass


func scan_for_item_target():
	var found_item: Node3D = null
	for n in detection_area.get_overlapping_bodies():
		if n is FoodItem:
			if found_item == null:
				found_item = n
			else:
				# Find the closest item
				if mob.global_position.distance_to(n.global_position) \
				< mob.global_position.distance_to(found_item.global_position):
					found_item = n
	item_target = found_item
	return


func on_bump_area_body_entered(body: Node3D):
	if body == item_target:
		var item = item_target
		item_target = null
		item.queue_free()
		

func handle_step(delta: float):
	var desired_step_to_global_y: float = step_checker.can_step(mob.direction, delta).y
	if desired_step_to_global_y == 0:
		if not mob.is_on_floor():
			mob.apply_gravity(delta)
	else:
		var desired_step_to_relative_y: float = desired_step_to_global_y - mob.global_position.y
		if desired_step_to_relative_y > 0 and desired_step_to_relative_y < step_checker.step_height:
			desired_step_to_relative_y = step_checker.step_height
			# TODO do we really need step_height if we have the wall_check?
		mob.velocity.y = desired_step_to_relative_y * mob.move_speed * 2
		# Disable gravity if we are stepping up
		if desired_step_to_relative_y <= 0:
			if not mob.is_on_floor():
				mob.apply_gravity(delta)
