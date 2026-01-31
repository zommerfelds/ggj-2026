extends Node

@export var cameraPivot: Node3D

func _process(delta: float) -> void:
	var cameraPivotRotationY = cameraPivot.rotation.y
	for child in get_children():
		if (child is Node3D):
			var mesh = child.get_node_or_null("Face")
			if (mesh is Node3D):
				mesh.rotation.y = cameraPivotRotationY
