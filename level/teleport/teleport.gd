extends Area3D

class_name Teleport

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		# TODO: emit event for teleport
		%Regular.visible = false
		%Enabled.visible = true

func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		# TODO: emit event for teleport
		%Regular.visible = true
		%Enabled.visible = false
