extends Node3D

var targetRotationY = 45
var rotationSpeed = 90

func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("ui_accept")):
		targetRotationY += 90
		if (targetRotationY > 180):
			targetRotationY -= 360
	var rotationDiff = targetRotationY - rotation_degrees.y
	if (rotationDiff < 0):
		rotationDiff += 360
	var step = delta * rotationSpeed
	if (step > rotationDiff):
		rotation_degrees.y = targetRotationY
	else:
		rotate_y(deg_to_rad(step))
