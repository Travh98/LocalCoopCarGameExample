extends Node3D

@onready var print_paper_spot = $PrintPaperSpot
@onready var print_timer: Timer = $PrintTimer
@onready var printer_paper_scene = preload("res://entities/printer/printer_paper.tscn")
@onready var print_step_timer: Timer = $PrintStepTimer
@onready var printer_status_label: Label3D = $PrinterStatusLabel

var last_printed_item: RigidBody3D = null

var is_printing: bool = false
var print_steps: int = 0 # Number of print steps taken during printing
var max_print_steps: int = 10 # Max number of times to shift the paper forwards

var random_text_list = ["Your printer is running low on ink", "save the little people", "i wonder what you taste like", "good things await in the dark", "i am inside of your head", "HEALTH 100/100"]

func _ready():
	print_timer.timeout.connect(print_paper)
	print_step_timer.timeout.connect(print_step)
	printer_status_label.text = "idle"


func print_paper():
	if is_printing:
		return
	
	is_printing = true
	print_steps = 0
	
	# Spawn paper
	var paper: RigidBody3D = printer_paper_scene.instantiate()
	print_paper_spot.add_child(paper)
	paper.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	paper.freeze = true
	paper.get_node("CollisionShape3D").disabled = true
	paper.global_transform = print_paper_spot.global_transform
	# Move paper into the printer
	paper.position = paper.position - paper.transform.basis.z / 2
	# Store a reference to this paper
	last_printed_item = paper
	# Set random text onto the paper
	paper.get_node("PrinterPaperLabel").text = random_text_list[randi() % random_text_list.size()]
	print_step_timer.start()

	
func print_step():
	if print_steps < max_print_steps:
		print_steps += 1
		last_printed_item.position = last_printed_item.position + last_printed_item.transform.basis.z * 0.05
		print_step_timer.start()
		printer_status_label.text = "printing"
		match print_steps % 3:
			0:
				printer_status_label.text += "."
			1:
				printer_status_label.text += ".."
			2:
				printer_status_label.text += "..."
			_:
				printer_status_label.text = "error"
	else:
		is_printing = false
		last_printed_item.freeze = false
		last_printed_item.get_node("CollisionShape3D").disabled = false
		
		var printer_finish_pos: Vector3 = last_printed_item.global_position
		var new_parent = get_tree().root
		print_paper_spot.remove_child(last_printed_item)
		new_parent.add_child(last_printed_item)
		last_printed_item.scale = scale
		last_printed_item.global_position = printer_finish_pos
		
		
		printer_status_label.text = "idle"
