class_name SelectedLevel
extends Resource

@export var chapter: int
@export var level: int
@export var touch_ui_enabled: bool

func _init(chapter = 1, level = 0, touch_ui_enabled = false):
	self.chapter = chapter
	self.level = level
	self.touch_ui_enabled = touch_ui_enabled
