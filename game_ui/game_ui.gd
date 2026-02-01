extends Node


var level_preload = preload("res://level/level.tscn")
var paradox_void = preload("res://level/paradox_void/paradox_void.tscn")

@onready var level = $Level
var level_index = 1


func _ready() -> void:
	SignalBus.connect("goal_reached", next_level)
	SignalBus.connect("end_world", end_world)

func _process(delta) -> void:
	updateInstructionsText()
	$Overlay/LevelName.text = level.level_name
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
	call_deferred("setup_level")

func next_level(delta: int = 1) -> void:
	level.queue_free()
	level_index += delta
	call_deferred("setup_level")

func setup_level() -> void:
	%ParadoxLabel.visible = false
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
	tween.tween_callback(func ():
		print("set visible")
		%ParadoxLabel.visible = true
	)

func updateInstructionsText():
	var device_name = Input.get_joy_name(0)
	var model = "keyboard"
	if (device_name.contains("PS3")
			|| device_name.contains("PS4")
		 	|| device_name.contains("PS5")):
		model = "playstation"
	elif (device_name.contains("Xbox") || device_name.contains("XInput")):
		model = "xbox"
	elif (device_name.contains("Controller")
			|| device_name.contains("Gamepad")
			|| device_name.contains("Joy-Con")
			|| device_name.contains("Joy Con")):
		model = "controller"
	match model:
		"keyboard":
			%InstructionsKeyboard.visible = true
			%InstructionsController.visible = false
			%InstructionsPlaystation.visible = false
			%InstructionsXbox.visible = false
		"controller":
			%InstructionsKeyboard.visible = false
			%InstructionsController.visible = true
			%InstructionsPlaystation.visible = false
			%InstructionsXbox.visible = false
		"playstation":
			%InstructionsKeyboard.visible = false
			%InstructionsController.visible = false
			%InstructionsPlaystation.visible = true
			%InstructionsXbox.visible = false
		"xbox":
			%InstructionsKeyboard.visible = false
			%InstructionsController.visible = false
			%InstructionsPlaystation.visible = false
			%InstructionsXbox.visible = true
