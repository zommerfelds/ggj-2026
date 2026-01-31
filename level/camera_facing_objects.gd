extends Node

@export var cameraPivot: Node3D

func _process(delta: float) -> void:
	var cameraPivotRotationY = cameraPivot.rotation.y
	for child in get_children():
		if (child is Node3D):
			var childNode = child as Node3D
			childNode.rotation.y = cameraPivotRotationY
