extends Node3D

var targetRotationY = 45
var rotationSpeed = 90

var can_rotate = false

func _init() -> void:
	SignalBus.connect("can_rotate", set_can_rotate)


func _process(delta: float) -> void:
	if ((Input.is_action_just_pressed("rotate_right") || Input.is_action_just_pressed("touch_button")) and can_rotate):
		SignalBus.camera_rotated.emit()
		targetRotationY += 90
		if (targetRotationY > 180):
			targetRotationY -= 360
	if (Input.is_action_just_pressed("rotate_left") and can_rotate):
		SignalBus.camera_rotated.emit()
		targetRotationY -= 90
		if (targetRotationY < -180):
			targetRotationY += 360
	var rotationDiff = targetRotationY - rotation_degrees.y
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
