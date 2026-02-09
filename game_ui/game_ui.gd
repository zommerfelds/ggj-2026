extends Control


var level_preload = preload("res://level/level.tscn")
var paradox_void = preload("res://level/paradox_void/paradox_void.tscn")
var rotate_texture: Texture2D = load("res://game_ui/noun-rotate-8192423.svg")
var next_level_texture: Texture2D = load("res://game_ui/noun-next-1548812.svg")
var home_texture: Texture2D = load("res://game_ui/noun-home-4460073.svg")

var level: Node
var chapter_index = LevelSelector.get_res().chapter
var level_index = LevelSelector.get_res().level
var can_rotate = false
var time_since_interaction = 0.0
var times_camera_rotated = 0
var has_world_ended = false
var is_game_over = false
var is_rewinding = false
var paradox: Node3D
var tween: Tween
var state_history = []


func _ready() -> void:
	SignalBus.connect("goal_reached", goal_reached)
	SignalBus.connect("end_world", end_world)
	SignalBus.connect("can_rotate", set_can_rotate)
	SignalBus.connect("player_moved", player_moved)
	SignalBus.connect("camera_rotated", camera_rotated)
	SignalBus.connect("game_over", game_over)
	SignalBus.connect("select_level", select_level)

	setup_level()
	set_can_rotate(false)


func _physics_process(_delta: float) -> void:
	var should_rewind = Input.is_action_pressed("rewind") && !%WonLevel.visible
	if (is_rewinding != should_rewind) && can_interrupt():
		is_rewinding = should_rewind
		SignalBus.is_rewinding.emit(is_rewinding)
	if is_rewinding:
		rewind()
	elif time_since_interaction < 1.5:
		record()

func _process(delta) -> void:
	if is_rewinding:
		updateInstructionsText()
		return

	time_since_interaction += delta
	updateInstructionsText()
	$Overlay/LevelName.text = "Level %d:%d" % [chapter_index, level_index + 1]
	if level.level_name != "":
		$Overlay/LevelName.text = $Overlay/LevelName.text + " | %s" % level.level_name
	if (Input.is_action_pressed("skip_level_1") && Input.is_action_just_pressed("skip_level_2")
	 || Input.is_action_pressed("skip_level_2") && Input.is_action_just_pressed("skip_level_1")):
		next_level()
	if (Input.is_action_pressed("previous_level") && Input.is_action_just_pressed("skip_level_2")
	 || Input.is_action_pressed("skip_level_2") && Input.is_action_just_pressed("previous_level")):
		next_level(-1)
	if (Input.is_action_just_pressed("reset_level")):
		reset_level()
	if (%WonLevel.visible && (Input.is_action_just_pressed("continue") || Input.is_action_just_pressed("touch_button_right"))):
		next_level()

	var touch = Platform.show_touch_ui()
	if $Overlay/Touch.visible != touch:
		$Overlay/Touch.visible = touch
		for child in $Overlay/Touch.get_children():
			child.set_disabled(!touch)
		update_buttons()


func _on_visibility_changed() -> void:
	if visible:
		update_buttons()


func reset_level() -> void:
	level.queue_free()
	call_deferred("setup_level")


func next_level(delta: int = 1) -> void:
	var new = Level.level_offset(chapter_index, level_index, delta)
	select_level(new[0], new[1])


func select_level(chapter: int, index: int) -> void:
	level.queue_free()
	chapter_index = chapter
	level_index = index
	call_deferred("setup_level")


func setup_level() -> void:
	is_game_over = false
	time_since_interaction = 0.0
	%WonLevel.visible = false
	%WonLevelInstruction.visible = false
	has_world_ended = false
	if tween != null:
		tween.kill()
	tween = null
	paradox = null
	state_history = []
	%ParadoxBackdrop.visible = false
	%ParadoxLabel.visible = false
	level = level_preload.instantiate()
	level.chapter_index = chapter_index
	level.level_index = level_index
	add_child(level)
	update_buttons()

func end_world(source: Vector3) -> void:
	if has_world_ended:
		return
	has_world_ended = true
	time_since_interaction = 0.0
	paradox = paradox_void.instantiate()
	paradox.position = source
	level.add_child(paradox)
	var targetSize = 3 * max(level.grid_size.x, level.grid_size.z)
	tween = get_tree().create_tween()
	tween.tween_property(
		paradox,
		"scale",
		Vector3(targetSize, targetSize, targetSize),
		1.4
	)
	await tween.finished
	tween = null
	if has_world_ended:
		%ParadoxBackdrop.visible = true
		%ParadoxLabel.visible = true

func goal_reached():
	%WonLevel.visible = true
	var won_level_tween = get_tree().create_tween()
	won_level_tween.tween_callback(func ():
		if %WonLevel.visible:
			%WonLevelInstruction.visible = true
	).set_delay(3.0)
	update_buttons()


func updateInstructionsText():
	var rotationHintEnabled = times_camera_rotated < 2 || time_since_interaction > 6.0
	var instructionsEnabled = level_index < 2 || time_since_interaction > 3.0 || has_world_ended
	rotationHintEnabled = rotationHintEnabled && !is_rewinding && !has_world_ended
	instructionsEnabled = instructionsEnabled && !%WonLevel.visible && !is_game_over
	%InstructionsBackdrop.visible = instructionsEnabled
	%RotationGroup.visible = can_rotate && rotationHintEnabled

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

	match Platform.current_input_device:
		Platform.InputDevice.KEYBOARD:
			%InstructionsKeyboard.visible = instructionsEnabled
			%RotationInstructionsKeyboard.visible = true
			%WonLevelKeyboard.visible = true
		Platform.InputDevice.CONTROLLER:
			%InstructionsController.visible = instructionsEnabled
			%RotationInstructionsController.visible = true
			%WonLevelController.visible = true
		Platform.InputDevice.PLAYSTATION:
			%InstructionsPlaystation.visible = instructionsEnabled
			%RotationInstructionsPlaystation.visible = true
			%WonLevelPlaystation.visible = true
		Platform.InputDevice.XBOX:
			%InstructionsXbox.visible = instructionsEnabled
			%RotationInstructionsController.visible = true
			%WonLevelXbox.visible = true
		Platform.InputDevice.TOUCH:
			%InstructionsTouch.visible = instructionsEnabled
			%RotationInstructionsTouch.visible = true
			%WonLevelTouch.visible = true

	%GameOver.visible = is_game_over
	$Overlay/LevelName.visible = !is_game_over
	$Overlay/LevelNameBackdrop.visible = !is_game_over


func set_can_rotate(new_value: bool):
	can_rotate = new_value
	update_buttons()


func update_buttons():
	if not Platform.show_touch_ui():
		return

	%TouchButtonHome.set_texture(home_texture, false)

	var left_active = can_rotate
	var right_active = can_rotate or %WonLevel.visible

	%TouchButtonLeft.set_texture(rotate_texture if can_rotate else null, true)
	%TouchButtonLeft.visible = left_active
	%TouchButtonLeft.disabled = !left_active
	%TouchButtonLeft.queue_redraw()

	%TouchButtonRight.set_texture(rotate_texture if can_rotate else next_level_texture, false)
	%TouchButtonRight.visible = right_active
	%TouchButtonRight.disabled = !right_active
	%TouchButtonRight.queue_redraw()


func player_moved():
	time_since_interaction = 0.0

func camera_rotated():
	time_since_interaction = 0.0
	times_camera_rotated += 1

func game_over():
	is_game_over = true
	updateInstructionsText()


func can_interrupt(node: Node = self):
	if (node.has_method("is_interruptible")):
		var can_interrupt_node = node.is_interruptible()
		if !can_interrupt_node:
			return false
	for child in node.get_children():
		if !can_interrupt(child):
			return false
	return true

func rewind(node: Node = self):
	if (node.has_method("load_state")):
		node.load_state()
	for child in node.get_children():
		rewind(child)

func record(node: Node = self):
	if (node.has_method("save_state")):
		node.save_state()
	for child in node.get_children():
		record(child)

func is_interruptible() -> bool:
	return tween == null && !(is_rewinding && has_world_ended)

func load_state():
	time_since_interaction = 0.0
	if state_history.is_empty():
		if has_world_ended:
			has_world_ended = false
			SignalBus.un_end_world.emit()
		if paradox != null:
			level.remove_child(paradox)
			paradox.queue_free()
			paradox = null
	else:
		var state = state_history.pop_back()
		paradox.scale = state["paradox.scale"]
		%ParadoxBackdrop.visible = state["%ParadoxBackdrop.visible"]
		%ParadoxLabel.visible = state["%ParadoxLabel.visible"]

func save_state():
	if has_world_ended:
		state_history.push_back({
			"paradox.scale": paradox.scale,
			"%ParadoxBackdrop.visible": %ParadoxBackdrop.visible,
			"%ParadoxLabel.visible": %ParadoxLabel.visible,
		})
