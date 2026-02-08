class_name SelectedLevel
extends Resource

@export var chapter: int
@export var level: int

func _init(chapter = 1, level = 0):
	self.chapter = chapter
	self.level = level
