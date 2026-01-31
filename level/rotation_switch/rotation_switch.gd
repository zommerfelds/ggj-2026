extends Area3D


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		SignalBus.can_rotate.emit(true)


func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		SignalBus.can_rotate.emit(false)
