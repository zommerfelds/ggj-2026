extends Node3D

@export var cameraPivot: Node3D

const RAY_LENGTH = 10000

func _process(delta: float) -> void:
	var cameraPivotRotationY = cameraPivot.rotation.y
	for child in get_children():
		if (child is Node3D):
			var mesh = child.get_node_or_null("Face")
			if (mesh is Node3D):
				mesh.rotation.y = cameraPivotRotationY
				mesh.rotation_degrees.x = 60

func _physics_process(delta: float) -> void:
	for child in get_children():
		if (child is Node3D && !(child is Player) && !(child is Plant)):
			var isObjectMasked = checkIfObjectIsMasked(child)
			child.process_mode = Node.PROCESS_MODE_DISABLED if isObjectMasked else Node.PROCESS_MODE_INHERIT
		if child is Node3D && !(child is Player):
			if checkForParadox(child as Node3D):
				SignalBus.end_world.emit((child as Node3D).global_position)

func checkIfObjectIsMasked(object: Node3D) -> bool:
	var space_state = object.get_world_3d().direct_space_state
	var directionToCamera = Vector3(0,0.577,1).rotated(Vector3(0,1,0), cameraPivot.rotation.y)
	var target = object.global_position + directionToCamera * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(object.global_position, target, 2)
	query.collide_with_areas = true
	var result = space_state.intersect_ray(query)
	return result.get("collider") != null

func checkForParadox(object: Node3D) -> bool:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsPointQueryParameters3D.new()
	query.position = object.global_position
	var result = space_state.intersect_point(query)
	return result.size() > 1
