extends Node3D


@export var level_index: int = 0

var rock_scene = preload("uid://gspapybfyiaj")
var plant_scene = preload("res://level/plant/plant.tscn")
var goal_scene = preload("res://level/goal/goal.tscn")
var player_scene = preload("res://Player/Player.tscn")
var rotation_switch_scene = preload("res://level/rotation_switch/rotation_switch.tscn")
var box_scene = preload("res://level/box/box.tscn")
var tall_bush_scene = preload("res://level/tall_bush/tall_bush.tscn")


# Only X and Z matter for the grid size
var grid_size: Vector3i = Vector3i(6, -1, 8)

func _ready() -> void:

	match level_index:
		1:
			grid_size = Vector3i(5, -1, 5)
			add_goal(0, 1)
			add_rock(2, 0)
			add_rock(2, 1)
			add_rock(2, 2)
			add_rock(2, 3)
			add_player(4, 1)
		2:
			grid_size = Vector3i(5, -1, 5)
			add_goal(1, 2)
			add_plant(2, 3)
			add_plant(3, 2)
			add_player(2, 1)
		3:
			grid_size = Vector3i(5, -1, 5)
			add_goal(1, 1)
			add_tall_bush(2, 2)
			add_player(4, 1)
			add_rotation_switch(4, 2)
		4:
			grid_size = Vector3i(6, -1, 4)
			add_goal(0, 0)
			for x in 4:
				add_rock(1, x)
			add_plant(4, 3)
			add_player(4, 1)
		5:
			grid_size = Vector3i(5, -1, 5)
			add_goal(0, 4)
			add_rock(1, 4)
			add_rock(0, 3)
			add_plant(2, 2)
			add_player(0, 1)
			add_rotation_switch(4, 2)
		6:
			grid_size = Vector3i(5, -1, 5)
			add_goal(2, 2)
			add_rock(2, 3)
			add_rock(3, 2)
			add_rock(2, 1)
			add_rock(1, 2)

			add_plant(1, 1)
			add_plant(1, 3)
			add_plant(3, 1)
			add_plant(3, 3)
			add_plant(1, 4)

			add_player(4, 0)
			add_rotation_switch(4, 1)
		7:
			grid_size = Vector3i(5, -1, 5)
			add_goal(0, 0)
			add_rock(0, 1)
			add_rock(0, 2)
			add_rock(1, 0)
			add_rock(2, 0)

			add_plant(2, 1)
			add_plant(2, 2)
			add_plant(1, 2)

			add_player(4, 4)
		8:
			grid_size = Vector3i(4, -1, 4)
			add_goal(3, 0)
			add_box(1, 0)
			add_box(0, 1)
			add_box(3, 2)
			add_box(1, 1)
			add_plant(1, 2)
			add_player(3, 3)
		_:
			grid_size = Vector3i(6, -1, 6)
			add_rock(1, 3)
			add_box(3, 1)
			add_plant(2, 2)
			add_goal(1, 1)
			add_player(4, 4)
			add_rotation_switch(0, 4)

	# Resize floor:
	$Floor/FloorMesh.mesh.size = Vector2(grid_size.x, grid_size.z)
	$Floor/FloorMesh.get_surface_override_material(0).uv1_scale = Vector3(grid_size.x, grid_size.z, 1)
	$CameraPivot.position = Vector3(grid_size.x / 2.0, 0, grid_size.z / 2.0)
	$Floor/FloorMesh.position = $CameraPivot/FloorReference.global_position

	# Create wall collision shapes:
	var walls = StaticBody3D.new()
	var box_shape = BoxShape3D.new()
	var prototype = CollisionShape3D.new()
	box_shape.size = Vector3(grid_size.x, 1.0, grid_size.z)
	prototype.shape = box_shape
	prototype.position = Vector3(grid_size.x / 2.0, 0.5, grid_size.z / 2.0)
	for i in [Vector3(-1, 0, 0), Vector3(1, 0, 0), Vector3(0, 0, -1), Vector3(0, 0, 1)]:
		var wall = prototype.duplicate()
		wall.position += i * wall.shape.size
		walls.add_child(wall)
	add_child(walls)
	prototype.free()

	$CameraPivot/Camera3D.size = max(grid_size.x, grid_size.z)


func _process(delta: float) -> void:
	$Floor/FloorMesh.position = $CameraPivot/FloorReference.global_position


func add_player(x, z) -> void:
	var player = player_scene.instantiate()
	player.position = Vector3(x + 0.5, 0.0, z + 0.5)
	player.camera = $CameraPivot/Camera3D
	$Objects.add_child(player)


func add_rock(x, z) -> void:
	var rock = rock_scene.instantiate()
	rock.position = Vector3(x + 0.5, 0, z + 0.5)
	$Objects.add_child(rock)


func add_plant(x, z) -> void:
	var plant = plant_scene.instantiate()
	plant.position = Vector3(x + 0.5, 0, z + 0.5)
	$Objects.add_child(plant)


func add_tall_bush(x, z) -> void:
	var tall_bush = tall_bush_scene.instantiate()
	tall_bush.position = Vector3(x + 0.5, 0, z + 0.5)
	$Objects.add_child(tall_bush)


func add_goal(x, z) -> void:
	var goal = goal_scene.instantiate()
	goal.position = Vector3(x + 0.5, 0, z + 0.5)
	$Objects.add_child(goal)


func add_rotation_switch(x, z) -> void:
	var rotation_switch = rotation_switch_scene.instantiate()
	rotation_switch.position = Vector3(x + 0.5, 0, z + 0.5)
	$Objects.add_child(rotation_switch)


func add_box(x, z) -> void:
	var box = box_scene.instantiate()
	box.position = Vector3(x + 0.5, 0, z + 0.5)
	$Objects.add_child(box)
