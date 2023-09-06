extends Control

# Video Settings
@onready var display_mode_options: OptionButton = $MarginContainer/TabContainer/Video/MarginContainer/GridContainer/DisplayModeOptions
@onready var vsync_button: CheckButton = $MarginContainer/TabContainer/Video/MarginContainer/GridContainer/VsyncButton
@onready var display_fps_button: CheckButton = $MarginContainer/TabContainer/Video/MarginContainer/GridContainer/DisplayFpsButton
@onready var max_fps_value: Label = $MarginContainer/TabContainer/Video/MarginContainer/GridContainer/MaxFpsSliderValue/MaxFpsValue
@onready var max_fps_slider: Slider = $MarginContainer/TabContainer/Video/MarginContainer/GridContainer/MaxFpsSliderValue/MaxFpsSlider
@onready var bloom_button: CheckButton = $MarginContainer/TabContainer/Video/MarginContainer/GridContainer/BloomButton
@onready var brightness_value: Label = $MarginContainer/TabContainer/Video/MarginContainer/GridContainer/BrightnessSliderValue/BrightnessValue
@onready var brightness_slider: Slider = $MarginContainer/TabContainer/Video/MarginContainer/GridContainer/BrightnessSliderValue/BrightnessSlider

# Audio Settings
@onready var master_volume_value: Label = $MarginContainer/TabContainer/Audio/MarginContainer/GridContainer/MasterVolumeSliderValue/MasterVolumeValue
@onready var master_volume_slider: Slider = $MarginContainer/TabContainer/Audio/MarginContainer/GridContainer/MasterVolumeSliderValue/MasterVolumeSlider
@onready var music_volume_value: Label = $MarginContainer/TabContainer/Audio/MarginContainer/GridContainer/MusicVolumeSliderValue/MusicVolumeValue
@onready var music_volume_slider: Slider = $MarginContainer/TabContainer/Audio/MarginContainer/GridContainer/MusicVolumeSliderValue/MusicVolumeSlider
@onready var sfx_volume_value: Label = $MarginContainer/TabContainer/Audio/MarginContainer/GridContainer/SfxVolumeSliderValue3/SfxVolumeValue
@onready var sfx_volume_slider: Slider = $MarginContainer/TabContainer/Audio/MarginContainer/GridContainer/SfxVolumeSliderValue3/SfxVolumeSlider

# Gameplay Settings
@onready var fov_value: Label = $MarginContainer/TabContainer/Gameplay/MarginContainer/GridContainer/FovSliderValue/FovValue
@onready var fov_slider: Slider = $MarginContainer/TabContainer/Gameplay/MarginContainer/GridContainer/FovSliderValue/FovSlider
@onready var mouse_sens_value: Label = $MarginContainer/TabContainer/Gameplay/MarginContainer/GridContainer/MouseSensitivitySliderValue/MouseSensitivityValue
@onready var mouse_sens_slider: Slider = $MarginContainer/TabContainer/Gameplay/MarginContainer/GridContainer/MouseSensitivitySliderValue/MouseSensitivitySlider


func _ready():
	display_mode_options.item_selected.connect(on_display_mode_changed)
	vsync_button.toggled.connect(toggle_vsync)
	display_fps_button.toggled.connect(toggle_display_fps)
	max_fps_slider.value_changed.connect(on_max_fps_changed)
	bloom_button.toggled.connect(toggle_bloom)
	brightness_slider.value_changed.connect(on_brightness_changed)
	
	master_volume_slider.value_changed.connect(set_master_vol)
	music_volume_slider.value_changed.connect(set_music_vol)
	sfx_volume_slider.value_changed.connect(set_sfx_vol)
	
	fov_slider.value_changed.connect(on_fov_changed)
	mouse_sens_slider.value_changed.connect(on_mouse_sens_changed)
	
	visibility_changed.connect(on_visiblity_changed)
	
	load_saved_settings()


func on_visiblity_changed():
	if visible:
		mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		# Save settings every time settings menu is hidden/closed
		save_current_settings()


func on_display_mode_changed(index: int):
	match index:
		0:
			GlobalSettings.toggle_fullscreen(false)
		1:
			GlobalSettings.toggle_fullscreen(true)
		_:
			GlobalSettings.toggle_fullscreen(false)


func toggle_vsync(button_pressed: bool):
	GlobalSettings.toggle_vsync(button_pressed)
	pass


func toggle_display_fps(button_pressed: bool):
	GlobalSettings.toggle_display_fps(button_pressed)


func on_max_fps_changed(max_fps: int):
	max_fps_value.text = str(max_fps)


func toggle_bloom(button_pressed: bool):
	GlobalSettings.toggle_bloom(button_pressed)


func on_brightness_changed(brightness: float):
	GlobalSettings.update_brightness(brightness)
	brightness_value.text = str(brightness)


func set_master_vol(vol: float):
	GlobalSettings.update_master_vol(vol)
	master_volume_value.text = str(vol)


func set_music_vol(vol: float):
	GlobalSettings.update_music_vol(vol)
	music_volume_value.text = str(vol)


func set_sfx_vol(vol: float):
	GlobalSettings.update_sfx_vol(vol)
	sfx_volume_value.text = str(vol)


func on_fov_changed(fov: int):
	GlobalSettings.update_fov(fov)
	fov_value.text = str(fov)


func on_mouse_sens_changed(mouse_sens: float):
	GlobalSettings.update_mouse_sens(mouse_sens)
	mouse_sens_value.text = str(mouse_sens)


func load_saved_settings():
	# Load the saved settings
	display_mode_options.select(1 if SaveSettings.game_data["fullscreen_on"] else 0)
	GlobalSettings.toggle_fullscreen(SaveSettings.game_data["fullscreen_on"]) # Manually call to emit signal
	vsync_button.set_pressed(SaveSettings.game_data["vsync_on"])
	display_fps_button.set_pressed(SaveSettings.game_data["display_fps"])
	max_fps_slider.set_value(SaveSettings.game_data["max_fps"])
	bloom_button.set_pressed(SaveSettings.game_data["bloom_on"])
	brightness_slider.set_value(SaveSettings.game_data["brightness"])
	
	master_volume_slider.set_value(SaveSettings.game_data["master_vol"])
	music_volume_slider.set_value(SaveSettings.game_data["music_vol"])
	sfx_volume_slider.set_value(SaveSettings.game_data["sfx_vol"])
	
	fov_slider.set_value(SaveSettings.game_data["fov"])
	mouse_sens_slider.set_value(SaveSettings.game_data["mouse_sens"])


func save_current_settings():
	if display_mode_options.get_index() == 1:
		SaveSettings.game_data["fullscreen_on"] = true
	else:
		SaveSettings.game_data["fullscreen_on"] = false
	SaveSettings.game_data["vsync_on"] = vsync_button.is_pressed()
	SaveSettings.game_data["display_fps"] = display_fps_button.is_pressed()
	SaveSettings.game_data["max_fps"] = max_fps_slider.value
	SaveSettings.game_data["bloom_on"] = bloom_button.is_pressed()
	SaveSettings.game_data["brightness"] = brightness_slider.value
	
	SaveSettings.game_data["master_vol"] = master_volume_slider.value
	SaveSettings.game_data["music_vol"] = music_volume_slider.value
	SaveSettings.game_data["sfx_vol"] = sfx_volume_slider.value
	
	SaveSettings.game_data["fov"] = fov_slider.value
	SaveSettings.game_data["mouse_sens"] = mouse_sens_slider.value
