extends Node3D

var targetRotationY = 45

var can_rotate = false
var tween: Tween

func _init() -> void:
	SignalBus.connect("can_rotate", set_can_rotate)


func _process(delta: float) -> void:
	if can_rotate and tween == null:
		if Input.is_action_just_pressed("rotate_right") || Input.is_action_just_pressed("touch_button"):
			SignalBus.camera_rotated.emit()
			%AudioStreamPlayer.play()
			targetRotationY += 90
			_start_rotation()
		if Input.is_action_just_pressed("rotate_left"):
			SignalBus.camera_rotated.emit()
			%AudioStreamPlayer.play()
			targetRotationY -= 90
			_start_rotation()
		targetRotationY = wrapf(targetRotationY, -180, 180)


func _start_rotation() -> void:
	SignalBus.is_camera_rotating.emit(true)
	var rotationDiff = wrapf(targetRotationY - rotation_degrees.y, -180, 180)
	tween = get_tree().create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS) # For some reason this is needed to make the camera not twitching at the beginning and end
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "rotation_degrees:y", rotation_degrees.y + rotationDiff, 1.0)
	await tween.finished
	tween = null
	SignalBus.is_camera_rotating.emit(false)
	


func set_can_rotate(new_value: bool) -> void:
	can_rotate = new_value
