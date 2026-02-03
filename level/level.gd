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
var level_name = ""

func _ready() -> void:
	match level_index:
		1:
			level_name = "Welcome!"
			grid_size = Vector3i(5, -1, 5)
			add_goal(0, 1)
			add_bush(2, 0)
			add_bush(2, 1)
			add_bush(2, 2)
			add_bush(2, 3)
			add_player(4, 1)
		2:
			level_name = "Boxes can be pushed!"
			grid_size = Vector3i(5, -1, 5)
			add_goal(0, 0)
			add_bush(4, 1)
			add_box(3, 1)
			add_box(3, 2)
			add_bush(3, 3)
			add_box(2, 2)
			add_bush(1, 2)
			add_bush(1, 3)
			add_bush(1, 4)
			add_bush(2, 0)
			add_player(4, 2)
		3:
			level_name = "Potted plants can be pushed, too!"
			grid_size = Vector3i(5, -1, 6)
			add_goal(0, 0)
			add_tall_bush(0, 3)
			add_tall_bush(1, 3)
			add_tall_bush(2, 3)
			add_plant(3, 3)
			add_tall_bush(4, 3)
			add_player(2, 5)
		4:
			level_name = "Is something hiding here?"
			grid_size = Vector3i(5, -1, 5)
			add_goal(1, 2)
			add_plant(2, 3)
			add_plant(4, 2)
			add_player(3, 1)
		5:
			level_name = "Where did it go?"
			grid_size = Vector3i(5, -1, 5)
			add_goal(0, 3)
			add_player(3, 2)
			add_bush(0, 1)
			add_bush(0, 2)
			add_bush(2, 1)
			add_bush(2, 2)
			add_bush(2, 3)
			add_bush(3, 3)
			add_bush(4, 3)
			add_plant(1, 1)
		6:
			level_name = "Perspective matters!"
			grid_size = Vector3i(5, -1, 5)
			add_goal(1, 1)
			add_tall_bush(2, 2)
			add_player(4, 1)
			add_rotation_switch(4, 2)
		7:
			level_name = "What if I can't see it?"
			grid_size = Vector3i(6, -1, 5)
			add_goal(0, 1)
			add_player(4, 2)
			for x in 5:
				add_bush(3, x)
			add_tall_bush(4, 0)
			add_tall_bush(1, 0)
			add_rotation_switch(0, 4)
			add_rotation_switch(5, 4)
		8:
			level_name = "Magic trick"
			grid_size = Vector3i(6, -1, 5)
			add_player(0, 4)
			add_bush(2, 4)
			add_bush(2, 3)
			add_bush(2, 2)
			add_bush(1, 0)
			add_bush(2, 0)
			add_bush(4, 0)
			add_tall_bush(4, 2)
			add_box(1, 1)
			add_goal(5, 4)
		9:
			level_name = "Push to hide"
			grid_size = Vector3i(6, -1, 4)
			add_goal(0, 0)
			for y in 6:
				add_bush(y, 1)
			add_bush(2, 0)
			add_plant(4, 2)
			add_player(4, 0)
		10:
			level_name = "A pair of bushes"
			grid_size = Vector3i(5, -1, 5)
			add_goal(0, 4)
			add_bush(1, 4)
			add_bush(0, 3)
			add_plant(2, 2)
			add_player(0, 1)
			add_rotation_switch(4, 2)
		11:
			level_name = "Two layers"
			grid_size = Vector3i(7, -1, 5)
			for i in range(5):
				add_bush(1, i)
				add_bush(3, i)
			add_plant(5, 1)
			add_plant(5, 3)
			add_goal(0, 2)
			add_player(6, 2)
		12:
			level_name = "To rotate or not to rotate"
			grid_size = Vector3i(5, -1, 4)
			for i in range(4):
				add_bush(3, i)
			add_plant(0, 2)
			add_rotation_switch(1, 1)
			add_tall_bush(2, 0)
			add_goal(4, 2)
			add_player(2, 2)
		13:
			level_name = "It's getting crowded in here!"
			grid_size = Vector3i(5, -1, 5)
			add_goal(2, 2)
			add_bush(2, 3)
			add_bush(3, 2)
			add_bush(2, 1)
			add_bush(1, 2)

			add_plant(1, 1)
			add_plant(1, 3)
			add_plant(3, 1)
			add_plant(3, 3)
			add_plant(1, 4)

			add_player(4, 0)
			add_rotation_switch(4, 1)
		14:
			level_name = "Ramping up the challenge"
			grid_size = Vector3i(5, -1, 5)
			add_goal(0, 4)
			add_bush(1, 4)
			add_bush(2, 4)
			add_bush(0, 3)
			add_bush(0, 2)

			add_plant(2, 3)
			add_plant(2, 2)
			add_plant(1, 2)
			add_rotation_switch(4, 0)

			add_player(4, 4)
		15:
			level_name = "Palace garden"
			grid_size = Vector3i(7, -1, 7)
			add_plant(3, 5)
			add_player(6, 6)
			add_rotation_switch(3, 4)
			for i in range(2, 5):
				add_bush(i, 3)
			for i in range(0, 4):
				add_bush(1, i)
				add_bush(5, i)
			add_plant(4, 2)
			add_plant(2, 2)
			add_plant(4, 0)
			add_plant(2, 0)
			add_goal(3, 1)
			add_bush(2, 4)
			add_bush(4, 4)
			add_bush(1, 5)
			add_bush(5, 5)
		16:
			level_name = "Tall bushes all around"
			grid_size = Vector3i(5, -1, 7)
			add_bush(1, 0)
			add_rotation_switch(0, 1)
			add_tall_bush(2, 1)
			add_tall_bush(4, 1)
			add_tall_bush(2, 2)
			add_goal(3, 2)
			add_tall_bush(0, 3)
			add_plant(2, 3)
			add_bush(3, 3)
			add_tall_bush(4, 3)
			add_tall_bush(1, 4)
			add_player(3, 4)
			add_tall_bush(4, 4)
			add_bush(2, 5)
			add_bush(0, 6)
		17:
			level_name = "Too late"
			grid_size = Vector3i(8, -1, 6)
			add_bush(7, 3)
			add_goal(7, 4)
			add_bush(6, 3)
			add_bush(6, 4)
			add_bush(6, 5)
			add_tall_bush(5, 0)
			for i in range(6):
				add_bush(4, i)
			add_plant(3, 2)
			add_rotation_switch(2, 3)
			add_tall_bush(1, 2)
			add_plant(1, 4)
			add_bush(1, 5)
			add_bush(0, 4)
			add_player(0, 0)
		18:
			level_name = "Soko soko"
			grid_size = Vector3i(5, -1, 5)
			add_bush(0, 1)
			add_bush(1, 0)
			add_goal(0, 0)
			add_player(4, 0)
			add_plant(3, 1)
			add_box(2, 2)
			add_box(1, 2)
			add_box(2, 1)
			add_bush(1, 1)
			add_box(3, 0)
			add_bush(2, 3)
			add_box(3, 3)
		19:
			level_name = "How do I get out of this?"
			grid_size = Vector3i(5, -1, 5)
			add_bush(2, 4)
			add_rotation_switch(4, 3)
			add_plant(3, 3)
			add_tall_bush(2, 3)
			add_tall_bush(0, 3)
			add_tall_bush(2, 2)
			add_goal(1, 2)
			add_bush(4, 1)
			add_plant(2, 1)
			add_bush(1, 1)
			add_tall_bush(0, 1)
			add_bush(1, 0)
			add_player(0, 4)
		20:
			level_name = "Don't get stuck!"
			grid_size = Vector3i(9, -1, 9)
			add_goal(0, 0)
			add_tall_bush(1,1)

			add_rotation_switch(4, 4)

			add_box(3,3)
			add_box(3,4)
			add_box(3,5)

			add_box(4,3)
			add_box(4,5)

			add_box(5,4)

			add_bush(5,5)
			add_bush(5,2)
			add_bush(2,3)
			add_bush(2,4)
			add_bush(4,2)
			add_bush(6,4)
			add_bush(6,3)
			add_bush(4,6)
			add_bush(6,5)

			add_plant(6,6)
			add_plant(1,7)
			add_player(0, 8)
		_:
			level_name = "Game over"
			grid_size = Vector3i(3, -1, 3)
			add_goal(2, 1)
			add_box(1, 2)
			add_plant(2, 0)
			add_rotation_switch(1,0)
			add_bush(0, 1)
			add_tall_bush(0, 2)
			add_player(1, 1)
			add_bush(0, 0)
			SignalBus.game_over.emit()

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

	update_camera_size()
	get_viewport().size_changed.connect(update_camera_size)


func _process(_delta: float) -> void:
	$Floor/FloorMesh.position = $CameraPivot/FloorReference.global_position


func add_player(x, z) -> void:
	var player = player_scene.instantiate()
	player.position = Vector3(x + 0.5, 0.0, z + 0.5)
	player.camera = $CameraPivot/Camera3D
	$Objects.add_child(player)


func add_bush(x, z) -> void:
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


func update_camera_size() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	var ratio_constraint = min(1, viewport_size.x / viewport_size.y / 1.5)
	$CameraPivot/Camera3D.size = max(grid_size.x, grid_size.z) / ratio_constraint
