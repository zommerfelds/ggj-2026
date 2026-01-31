extends Node


var level_preload = preload("res://level/level.tscn")
var paradox_void = preload("res://level/paradox_void/paradox_void.tscn")

@onready var level = $Level
var level_index = 1


func _ready() -> void:
	SignalBus.connect("goal_reached", next_level)
	SignalBus.connect("end_world", end_world)

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

func end_world(source: Vector3) -> void:
	var paradox = paradox_void.instantiate()
	paradox.position = source
	level.add_child(paradox)
	var targetSize = 3 * max(level.grid_size.x, level.grid_size.z)
	var tween = get_tree().create_tween()
	tween.tween_property(
		paradox,
		"scale",
		Vector3(targetSize, targetSize, targetSize),
		1.5
	)
