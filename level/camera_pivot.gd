extends Node3D

var targetRotationY = 45
var prevRotationY = 45

var can_rotate = false
var is_rewinding = false
var tween: Tween

var state_history = []

func _init() -> void:
	SignalBus.connect("can_rotate", set_can_rotate)
	SignalBus.connect("is_rewinding", on_is_rewinding)


func _process(_delta: float) -> void:
	if can_rotate and !is_rewinding and tween == null:
		if Input.is_action_just_pressed("rotate_right") || Input.is_action_just_pressed("touch_button_right"):
			SignalBus.camera_rotated.emit()
			%AudioStreamPlayer.play()
			targetRotationY += 90
			_start_rotation()
		if (Input.is_action_just_pressed("rotate_left") || Input.is_action_just_pressed("touch_button_left")):
			SignalBus.camera_rotated.emit()
			%AudioStreamPlayer.play()
			targetRotationY -= 90
			_start_rotation()
		targetRotationY = wrapf(targetRotationY, -180, 180)


func _start_rotation() -> void:
	SignalBus.is_camera_rotating.emit(true)
	var rotationDiff = wrapf(targetRotationY - prevRotationY, -180, 180)
	rotation_degrees.y = prevRotationY
	tween = get_tree().create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS) # For some reason this is needed to make the camera not twitch at the beginning and end
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "rotation_degrees:y", rotation_degrees.y + rotationDiff, 1.0)
	await tween.finished
	prevRotationY = targetRotationY
	tween = null
	SignalBus.is_camera_rotating.emit(false)


func set_can_rotate(new_value: bool) -> void:
	can_rotate = new_value

func on_is_rewinding(is_rewinding_: bool):
	is_rewinding = is_rewinding_
	if is_rewinding && tween != null:
		tween.kill()
		tween = null
	if !is_rewinding && prevRotationY != targetRotationY:
		_start_rotation()
		if state_history.size() > 0:
			var tween_elapsed_time = state_history.back()["tween_elapsed_time"]
			tween.custom_step(tween_elapsed_time)

func save_state():
	var tween_elapsed_time = 0.0
	if tween != null:
		tween_elapsed_time = tween.get_total_elapsed_time()
	state_history.push_back({
		"rotation_degrees": rotation_degrees,
		"targetRotationY": targetRotationY,
		"prevRotationY": prevRotationY,
		"tween_elapsed_time": tween_elapsed_time,
		"can_rotate": can_rotate,
	})

func load_state():
	var state = state_history.pop_back()
	if state == null:
		return

	rotation_degrees = state["rotation_degrees"]
	targetRotationY = state["targetRotationY"]
	prevRotationY = state["prevRotationY"]
	can_rotate = state["can_rotate"]
