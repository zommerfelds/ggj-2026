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


var always_allow_rotation = false:
	set(value):
		always_allow_rotation = value
		# This isn't correct if the player is on a rotation tile when unchecking,
		# but it's close enough for a debug setting.
		SignalBus.can_rotate.emit(value)
		save_state()


func _init() -> void:
	load_state()


func load_state() -> void:
	var data = FileIO.read_json_dict(SETTINGS_FILE)

	debug_mode = bool(data.get("debug_mode", debug_mode))
	sound_enabled = bool(data.get("sound_enabled", sound_enabled))
	diagonal_arrow_keys = bool(data.get("diagonal_arrow_keys", diagonal_arrow_keys))
	always_show_touch_ui = bool(data.get("always_show_touch_ui", always_show_touch_ui))
	always_allow_rotation = bool(data.get("always_allow_rotation", always_allow_rotation))


func save_state() -> void:
	var data = {
		"debug_mode" : debug_mode,
		"sound_enabled": sound_enabled,
		"diagonal_arrow_keys" : diagonal_arrow_keys,
		"always_show_touch_ui" : always_show_touch_ui,
		"always_allow_rotation" : always_allow_rotation,
	}
	FileIO.save_json_dict(SETTINGS_FILE, data)
