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
	%NextChapter.connect("pressed", _read_text_and_update_level.bind(1, 0))
	%PrevChapter.connect("pressed", _read_text_and_update_level.bind(-1, 0))
	%TextChapter.connect("text_changed", _read_text_and_update_level.bind(0, 0).unbind(1))

	%NextLevel.connect("pressed", _read_text_and_update_level.bind(0, 1))
	%PrevLevel.connect("pressed", _read_text_and_update_level.bind(0, -1))
	%TextLevel.connect("text_changed", _read_text_and_update_level.bind(0, 0).unbind(1))

	_update_text(get_res().chapter, get_res().level)


func _read_text_and_update_level(delta_chapter: int = 0, delta_level: int = 0) -> void:
	var chapter = int(%TextChapter.text) + delta_chapter
	var level = int(%TextLevel.text) - 1 + delta_level

	var config = get_res()
	config.chapter = chapter
	config.level = level
	ResourceSaver.save(config, "res://addons/level_selector/selected_level.tres")

	_update_text(chapter, level)


func _update_text(chapter: int, level: int) -> void:
	if %TextChapter.text != str(chapter):
		%TextChapter.text = str(chapter)
	if %TextLevel.text != str(level + 1):
		%TextLevel.text = str(level + 1)
