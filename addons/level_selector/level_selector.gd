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


func _ready() -> void:
	%ButtonNext.connect("pressed", _read_text_and_update_level.bind(1))
	%ButtonPrev.connect("pressed", _read_text_and_update_level.bind(-1))
	%LineEdit.connect("text_changed", _read_text_and_update_level.bind(0).unbind(1))
	_update_text(get_res().level)


func _read_text_and_update_level(offset_to_add: int = 0) -> void:
	var level = int(%LineEdit.text) + offset_to_add

	print("Setting start level to ", level)
	var config = get_res()
	config.level = level
	ResourceSaver.save(config, "res://addons/level_selector/selected_level.tres")

	_update_text(level)


func _update_text(level: int) -> void:
	if %LineEdit.text != str(level):
		%LineEdit.text = str(level)
