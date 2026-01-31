extends Node


var level_preload = preload("res://level/level.tscn")

@onready var level = $Level
var level_index = 1


func _ready() -> void:
	SignalBus.connect("goal_reached", next_level)

func _process(delta) -> void:
	if (Input.is_action_pressed("skip_level_1") && Input.is_action_just_pressed("skip_level_2")
	 || Input.is_action_pressed("skip_level_2") && Input.is_action_just_pressed("skip_level_1")):
		next_level()
	if (Input.is_action_pressed("previous_level") && Input.is_action_just_pressed("skip_level_2")
	 || Input.is_action_pressed("skip_level_2") && Input.is_action_just_pressed("previous_level")):
		next_level(-1)
	if (Input.is_action_just_pressed("reset_level")):
		reset_level()

func reset_level() -> void:
	level.queue_free()
	level = level_preload.instantiate()
	level.level_index = level_index
	add_child(level)

func next_level(delta: int = 1) -> void:
	level.queue_free()

	level_index += delta
	$Overlay/LevelName.text = "Level %d" % level_index
	level = level_preload.instantiate()
	level.level_index = level_index
	add_child(level)
