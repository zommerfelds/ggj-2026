@tool
class_name LevelSelector extends Control

# This plugin works by setting a resource file with the desired level number.
# When the game loads it will load from that resource file if it exists.

static func get_res() -> SelectedLevel:
	const res = "res://addons/level_selector/selected_level.tres"
	var config = SelectedLevel.new()
	if ResourceLoader.exists(res):
		config = load(res) as SelectedLevel
	return config


var _level = get_res().level

func _ready() -> void:
	%ButtonNext.connect("pressed", _read_text_and_update_level.bind(1))
	%ButtonPrev.connect("pressed", _read_text_and_update_level.bind(-1))
	%LineEdit.connect("text_submitted", _read_text_and_update_level.bind(0).unbind(1))
	_update_text()


func _read_text_and_update_level(offset_to_add: int = 0) -> void:
	_level = int(%LineEdit.text) + offset_to_add

	var config = get_res()
	config.level = _level
	ResourceSaver.save(config, "res://addons/level_selector/selected_level.tres")

	_update_text()


func _update_text() -> void:
	%LineEdit.text = str(_level)
