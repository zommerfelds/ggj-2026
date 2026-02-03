extends Node3D

var targetRotationY = 45
var rotationSpeed = 90

var can_rotate = false
var is_rotating = false

func _init() -> void:
	SignalBus.connect("can_rotate", set_can_rotate)


func _process(delta: float) -> void:
	if !is_rotating:
		if ((Input.is_action_just_pressed("rotate_right") || Input.is_action_just_pressed("touch_button")) and can_rotate):
			SignalBus.camera_rotated.emit()
			%AudioStreamPlayer.play()
			targetRotationY += 90
			if (targetRotationY > 180):
				targetRotationY -= 360
		if (Input.is_action_just_pressed("rotate_left") and can_rotate):
			SignalBus.camera_rotated.emit()
			%AudioStreamPlayer.play()
			targetRotationY -= 90
			if (targetRotationY < -180):
				targetRotationY += 360
	var rotationDiff = targetRotationY - rotation_degrees.y
	var is_now_rotating = rotationDiff != 0
	if is_now_rotating != is_rotating:
		is_rotating = is_now_rotating
		SignalBus.is_camera_rotating.emit(is_rotating)
	if (rotationDiff < -180):
		rotationDiff += 360
	if (rotationDiff > 180):
		rotationDiff -= 360
	if rotationDiff > 0:
		var step = delta * rotationSpeed
		if (step > rotationDiff):
			rotation_degrees.y = targetRotationY
		else:
			rotate_y(deg_to_rad(step))
	else:
		var step = -delta * rotationSpeed
		if (step < rotationDiff):
			rotation_degrees.y = targetRotationY
		else:
			rotate_y(deg_to_rad(step))


func set_can_rotate(new_value: bool) -> void:
	can_rotate = new_value
