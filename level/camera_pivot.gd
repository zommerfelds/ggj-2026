extends Node3D

var targetRotationY = 45

var can_rotate = false
var is_rewinding = false
var has_world_ended = false
var tween: Tween

var state_history = []

func _init() -> void:
	SignalBus.connect("can_rotate", set_can_rotate)
	SignalBus.connect("is_rewinding", on_is_rewinding)
	SignalBus.connect("end_world", end_world)
	SignalBus.connect("un_end_world", on_un_end_world)


func _process(_delta: float) -> void:
	if can_rotate and !is_rewinding and tween == null and !has_world_ended:
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
	var rotationDiff = wrapf(targetRotationY - rotation_degrees.y, -180, 180)
	tween = get_tree().create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS) # For some reason this is needed to make the camera not twitch at the beginning and end
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "rotation_degrees:y", rotation_degrees.y + rotationDiff, 1.0)
	await tween.finished
	tween = null
	SignalBus.is_camera_rotating.emit(false)


func set_can_rotate(new_value: bool) -> void:
	can_rotate = new_value

func on_is_rewinding(is_rewinding_: bool):
	is_rewinding = is_rewinding_

func end_world(_v: Vector3):
	has_world_ended = true

func on_un_end_world():
	has_world_ended = false

func is_interruptible() -> bool:
	return (
		tween == null &&
		(
			state_history.is_empty() ||
			state_history.back()["is_interruptible"]
		)
	)

func save_state():
	state_history.push_back({
		"rotation_degrees_y": rotation_degrees.y,
		"is_interruptible": tween == null,
	})

func load_state():
	var state = state_history.pop_back()
	if state == null:
		return

	rotation_degrees.y = state["rotation_degrees_y"]
	targetRotationY = roundf(state["rotation_degrees_y"])
