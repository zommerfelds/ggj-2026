extends Node


var level_preload = preload("res://level/level.tscn")
var paradox_void = preload("res://level/paradox_void/paradox_void.tscn")

@onready var level = $Level
var level_index = 1
var can_rotate = false
var time_since_interaction = 0.0
var times_camera_rotated = 0
var has_world_ended = false
var is_game_over = false

func _ready() -> void:
	SignalBus.connect("goal_reached", goal_reached)
	SignalBus.connect("end_world", end_world)
	SignalBus.connect("can_rotate", set_can_rotate)
	SignalBus.connect("player_moved", player_moved)
	SignalBus.connect("camera_rotated", camera_rotated)
	SignalBus.connect("game_over", game_over)

	if not is_touch_device():
		$Overlay/Joystick.free()
		$Overlay/TouchButton.free()
		$Overlay/TouchButtonReset.free()
		$Overlay/TouchButtonLabel.free()


func _process(delta) -> void:
	time_since_interaction += delta
	updateInstructionsText()
	$Overlay/LevelName.text = "Level %d" % level_index
	if level.level_name != "":
		$Overlay/LevelName.text = $Overlay/LevelName.text + ": %s" % level.level_name
	if (Input.is_action_pressed("skip_level_1") && Input.is_action_just_pressed("skip_level_2")
	 || Input.is_action_pressed("skip_level_2") && Input.is_action_just_pressed("skip_level_1")):
		next_level()
	if (Input.is_action_pressed("previous_level") && Input.is_action_just_pressed("skip_level_2")
	 || Input.is_action_pressed("skip_level_2") && Input.is_action_just_pressed("previous_level")):
		next_level(-1)
	if (Input.is_action_just_pressed("reset_level")):
		reset_level()
	if (%WonLevel.visible && (Input.is_action_just_pressed("continue") || Input.is_action_just_pressed("touch_button"))):
		next_level()

func reset_level() -> void:
	level.queue_free()
	call_deferred("setup_level")

func next_level(delta: int = 1) -> void:
	level.queue_free()
	level_index += delta
	call_deferred("setup_level")

func setup_level() -> void:
	time_since_interaction = 0.0
	%WonLevel.visible = false
	%WonLevelInstruction.visible = false
	has_world_ended = false
	%ParadoxBackdrop.visible = false
	%ParadoxLabel.visible = false
	level = level_preload.instantiate()
	level.level_index = level_index
	add_child(level)

func end_world(source: Vector3) -> void:
	has_world_ended = true
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
		%ParadoxBackdrop.visible = true
		%ParadoxLabel.visible = true
	)

func goal_reached():
	%WonLevel.visible = true
	var tween = get_tree().create_tween()
	tween.tween_callback(func ():
		if %WonLevel.visible:
			%WonLevelInstruction.visible = true
	).set_delay(3.0)

func updateInstructionsText():
	var rotationHintEnabled = times_camera_rotated < 2 || time_since_interaction > 6.0
	var instructionsEnabled = level_index < 2 || time_since_interaction > 3.0 || has_world_ended
	instructionsEnabled = instructionsEnabled && !%WonLevel.visible && !is_game_over
	%InstructionsBackdrop.visible = instructionsEnabled
	%RotationGroup.visible = can_rotate && rotationHintEnabled
	var device_name = Input.get_joy_name(0)
	var model = "keyboard"
	if (device_name.contains("PS3")
			|| device_name.contains("PS4")
			|| device_name.contains("PS5")
			|| device_name.contains("DualSense")):
		model = "playstation"
	elif (device_name.contains("Xbox") || device_name.contains("XInput")):
		model = "xbox"
	elif (device_name.contains("Controller")
			|| device_name.contains("Gamepad")
			|| device_name.contains("Joy-Con")
			|| device_name.contains("Joy Con")):
		model = "controller"
	elif is_touch_device():
		model = "touch"

	%InstructionsKeyboard.visible = false
	%InstructionsController.visible = false
	%InstructionsPlaystation.visible = false
	%InstructionsXbox.visible = false
	%InstructionsTouch.visible = false
	%RotationInstructionsKeyboard.visible = false
	%RotationInstructionsController.visible = false
	%RotationInstructionsPlaystation.visible = false
	%RotationInstructionsTouch.visible = false
	%WonLevelKeyboard.visible = false
	%WonLevelController.visible = false
	%WonLevelPlaystation.visible = false
	%WonLevelXbox.visible = false
	%WonLevelTouch.visible = false

	match model:
		"keyboard":
			%InstructionsKeyboard.visible = instructionsEnabled
			%RotationInstructionsKeyboard.visible = true
			%WonLevelKeyboard.visible = true
		"controller":
			%InstructionsController.visible = instructionsEnabled
			%RotationInstructionsController.visible = true
			%WonLevelController.visible = true
		"playstation":
			%InstructionsPlaystation.visible = instructionsEnabled
			%RotationInstructionsPlaystation.visible = true
			%WonLevelPlaystation.visible = true
		"xbox":
			%InstructionsXbox.visible = instructionsEnabled
			%RotationInstructionsController.visible = true
			%WonLevelXbox.visible = true
		"touch":
			%InstructionsTouch.visible = instructionsEnabled
			%RotationInstructionsTouch.visible = true
			%WonLevelTouch.visible = true


func set_can_rotate(new_value: bool):
	can_rotate = new_value

func player_moved():
	time_since_interaction = 0.0

func camera_rotated():
	time_since_interaction = 0.0
	times_camera_rotated += 1

func game_over():
	$Overlay/LevelName.visible = false
	$Overlay/LevelNameBackdrop.visible = false
	is_game_over = true
	%GameOver.visible = true

static func is_touch_device() -> bool:
	if OS.get_name() == "Android" || OS.get_name() == "iOS":
		return true

	var window = JavaScriptBridge.get_interface("window")
	if window:
		var js_return = JavaScriptBridge.eval("(('ontouchstart' in window) || (navigator.MaxTouchPoints > 0) || (navigator.msMaxTouchPoints > 0));")
		if js_return == 1:
			return true

	return false
