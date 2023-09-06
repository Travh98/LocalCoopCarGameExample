extends Control

@onready var local_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/LocalButton
@onready var settings_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/SettingsButton
@onready var quit_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/QuitButton

@onready var settings_menu: Control = $SettingsMenu

@export var next_scene_path: String = "res://ui/join_screen.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	local_button.pressed.connect(load_next_scene)
	settings_button.pressed.connect(show_settings_menu)
	quit_button.pressed.connect(quit)


func load_next_scene():
	GameManager.change_level(next_scene_path)


func show_settings_menu():
	settings_menu.visible = true


func quit():
	get_tree().quit()
