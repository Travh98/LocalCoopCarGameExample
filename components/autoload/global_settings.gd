extends Node

signal display_fps_toggled(do_display: bool)
signal bloom_toggled(do_bloom: bool)
signal fov_updated(fov: int)
signal brightness_updated(brightness: float)
signal mouse_sens_updated(sens: float)


func toggle_fullscreen(do_fullscreen: bool):
	if do_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func toggle_vsync(do_vsync: bool):
	if do_vsync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


func toggle_display_fps(do_display: bool):
	# Overlay fps
	display_fps_toggled.emit(do_display)


func toggle_bloom(do_bloom: bool):
	# Toggle the Glow in the Environment
	bloom_toggled.emit(do_bloom)


func update_brightness(brightness: float):
	brightness_updated.emit(brightness)


func update_master_vol(vol: float):
	AudioServer.set_bus_volume_db(0, vol)


func update_music_vol(vol: float):
	AudioServer.set_bus_volume_db(1, vol)


func update_sfx_vol(vol: float):
	AudioServer.set_bus_volume_db(2, vol)


func update_fov(fov: int):
	fov_updated.emit(fov)


func update_mouse_sens(mouse_sens: float):
	mouse_sens_updated.emit(mouse_sens)
