extends Node


var level_preload = preload("res://level/level.tscn")

@onready var level = $Level
var level_index = 1


func _ready() -> void:
	SignalBus.connect("goal_reached", next_level)


func next_level() -> void:
	level.queue_free()

	level_index += 1
	$Overlay/LevelName.text = "Level %d" % level_index
	level = level_preload.instantiate()
	add_child(level)
