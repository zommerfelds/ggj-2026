extends Area3D

class_name RotationSwitch

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		SignalBus.can_rotate.emit(true)
		%Regular.visible = false
		%Enabled.visible = true

func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		SignalBus.can_rotate.emit(false)
		%Regular.visible = true
		%Enabled.visible = false
