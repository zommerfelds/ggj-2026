extends Node3D


@export var level_index: int = 0

var rock_scene = preload("res://level/rock/rock.tscn")
var plant_scene = preload("res://level/plant/plant.tscn")
var goal_scene = preload("res://level/goal/goal.tscn")


# Only X and Z matter for the grid size
var grid_size: Vector3i = Vector3i(6, -1, 8)

func _ready() -> void:

	match level_index:
		1:
			grid_size = Vector3i(4, -1, 4)
			add_plant(3, 0)
			add_goal(3, 3)
			set_player(0, 0)
		2:
			grid_size = Vector3i(4, -1, 4)
			add_rock(0, 3)
			add_plant(3, 0)
			add_goal(3, 3)
			set_player(0, 0)
		_:
			grid_size = Vector3i(6, -1, 6)
			add_rock(1, 3)
			add_rock(3, 1)
			add_plant(2, 2)
			add_goal(1, 1)
			set_player(4, 4)

	# Resize floor:
	$Floor/FloorMesh.mesh.size = Vector2(grid_size.x, grid_size.z)
	$Floor/FloorMesh.position.x = grid_size.x / 2
	$Floor/FloorMesh.position.z = grid_size.z / 2
	$Floor/FloorMesh.get_surface_override_material(0).uv1_scale = Vector3(grid_size.x, grid_size.z, 1)
	$CameraPivot.position = $Floor/FloorMesh.position


func set_player(x, z) -> void:
	$Objects/Player.position = Vector3(x + 0.5, 0, z + 0.5)


func add_rock(x, z) -> void:
	var rock = rock_scene.instantiate()
	$Objects.add_child(rock)
	rock.position = Vector3(x + 0.5, 0, z + 0.5)


func add_plant(x, z) -> void:
	var plant = plant_scene.instantiate()
	$Objects.add_child(plant)
	plant.position = Vector3(x + 0.5, 0, z + 0.5)


func add_goal(x, z) -> void:
	var goal = goal_scene.instantiate()
	$Objects.add_child(goal)
	goal.position = Vector3(x + 0.5, 0, z + 0.5)
