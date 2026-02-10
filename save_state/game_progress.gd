extends Node

const PROGRESS_FILE = "user://game_progress.json"


var _current_chapter: int = 1
var _current_level: int = 0


func _init() -> void:
	if LevelSelector.get_res().chapter != 1 or LevelSelector.get_res().level != 0:
		_current_chapter = LevelSelector.get_res().chapter
		_current_level = LevelSelector.get_res().level
	else:
		load_state()
		if _current_chapter == Level.chapters.size() - 1 || _current_chapter == 0:
			# Player won the game last time or found test levels. Reset progress.
			_current_chapter = 1
			_current_level = 0


func current_chapter() -> int:
	return _current_chapter


func current_level() -> int:
	return _current_level


func set_progress(chapter: int, level: int):
	if chapter == _current_chapter and level == _current_level:
		return

	_current_chapter = chapter
	_current_level = level
	save_state()


func load_state() -> void:
	var data = FileIO.read_json_dict(PROGRESS_FILE)

	_current_chapter = int(data.get("current_chapter", _current_chapter))
	_current_level = int(data.get("current_level", _current_level))


func save_state() -> void:
	var data = {
		"current_chapter": _current_chapter,
		"current_level": _current_level,
	}
	FileIO.save_json_dict(PROGRESS_FILE, data)
