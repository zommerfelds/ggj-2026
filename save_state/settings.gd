extends Node

const SETTINGS_FILE = "user://settings.json"

var debug_mode = false:
	set(value):
		debug_mode = value
		save_state()

var sound_enabled: bool = true:
	set(value):
		sound_enabled = value
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), not sound_enabled)
		save_state()

var diagonal_arrow_keys = false:
	set(value):
		diagonal_arrow_keys = value
		save_state()

var always_show_touch_ui = false:
	set(value):
		always_show_touch_ui = value
		# Platform is also a global and initialized after Settings.
		if Platform != null:
			Platform.detect_input_device()
		save_state()


func _init() -> void:
	load_state()


func load_state() -> void:
	if not FileAccess.file_exists(SETTINGS_FILE):
		return
	var settings_file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
	var json_string = settings_file.get_line()
	var json = JSON.new()

	if json.parse(json_string) != OK:
		printerr("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return

	var data = json.data
	debug_mode = bool(data.get("debug_mode", debug_mode))
	sound_enabled = bool(data.get("sound_enabled", sound_enabled))
	diagonal_arrow_keys = bool(data.get("diagonal_arrow_keys", diagonal_arrow_keys))
	always_show_touch_ui = bool(data.get("always_show_touch_ui", always_show_touch_ui))


func save_state() -> void:
	var save_dict = {
		"debug_mode" : debug_mode,
		"sound_enabled": sound_enabled,
		"diagonal_arrow_keys" : diagonal_arrow_keys,
		"always_show_touch_ui" : always_show_touch_ui,
	}
	var save_file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	save_file.store_line(JSON.stringify(save_dict))
