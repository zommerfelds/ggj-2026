extends Node3D
class_name Level


@export var chapter_index: int = 1
@export var level_index: int = 0

var rock_scene = preload("uid://gspapybfyiaj")
var plant_scene = preload("res://level/plant/plant.tscn")
var goal_scene = preload("res://level/goal/goal.tscn")
var player_scene = preload("res://Player/Player.tscn")
var torch_scene = preload("uid://0obkkupagfq0")
var rotation_switch_scene = preload("res://level/rotation_switch/rotation_switch.tscn")
var teleport_scene = preload("uid://chce6h7ihyutk")
var box_scene = preload("res://level/box/box.tscn")
var tall_bush_scene = preload("res://level/tall_bush/tall_bush.tscn")


# Only X and Z matter for the grid size
var grid_size: Vector3i
var level_name: String

func _ready() -> void:
	var chapter = chapters[clamp(chapter_index, 0, chapters.size() - 1)]
	var level_data = chapter[clamp(level_index, 0, chapter.size() - 1)]
	level_name = level_data.name
	grid_size = level_data.grid_size
	level_data.populate(self)

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


# Returns [chapter, level] of the level "delta" steps away (-1, 0 or 1).
static func level_offset(chapter: int, level: int, delta: int) -> Array[int]:
	var new_level = level + delta

	if new_level < 0:
		# Go to last level of previous chapter
		var new_chap = clamp(chapter - 1, 0, chapters.size() - 1)
		return [new_chap, chapters[new_chap].size() - 1]

	if new_level > chapters[chapter].size() - 1:
		# Go to first level of next chapter
		var new_chap = clamp(chapter + 1, 0, chapters.size() - 1)
		return [new_chap, 0]

	return [chapter, new_level]


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


func add_goal(x, z, disabled = false) -> void:
	var goal = goal_scene.instantiate()
	goal.position = Vector3(x + 0.5, 0, z + 0.5)
	if disabled:
		goal.disable_flag()
	$Objects.add_child(goal)


func add_torch(x, z) -> void:
	var obj = torch_scene.instantiate()
	obj.position = Vector3(x + 0.5, 0, z + 0.5)
	$Objects.add_child(obj)


func add_rotation_switch(x, z) -> void:
	var rotation_switch = rotation_switch_scene.instantiate()
	rotation_switch.position = Vector3(x + 0.5, 0, z + 0.5)
	$Objects.add_child(rotation_switch)


func add_teleport(x, z) -> void:
	var obj = teleport_scene.instantiate()
	obj.position = Vector3(x + 0.5, 0, z + 0.5)
	$Objects.add_child(obj)


func add_box(x, z) -> void:
	var box = box_scene.instantiate()
	box.position = Vector3(x + 0.5, 0, z + 0.5)
	$Objects.add_child(box)


func update_camera_size() -> void:
	# By default, the camera size scales with the window height, so to
	# support wide windows (scale limited in y dimension) we wouldn't
	# need to do anything special, just set a fixed camera size. To
	# support tall screens, we compute size_limit_x based on the
	# viewport aspect ratio, and the final value is chosen to show the
	# whole scene in both x and y dimensions.
	#
	# The magic numbers are based on how the isometric perspecive results
	# in X and Y direction, with some (imperfect) fudging for the tallness
	# of trees.

	var viewport_size = get_viewport().get_visible_rect().size
	var level_size = grid_size.x + grid_size.z

	var size_limit_x = level_size / 1.42 / (viewport_size.x / viewport_size.y)
	var size_limit_y = level_size / 2.1

	$CameraPivot/Camera3D.size = max(size_limit_y, size_limit_x)


# Container for the information about a single level.
class LevelData:
	var name: String
	var grid_size: Vector3i
	# Function to populate the level grid
	var populator: Callable

	func _init(n, x, z, pop):
		name = n
		grid_size = Vector3i(x, -1, z)
		populator = pop

	func populate(l: Level):
		populator.call(l)


static var chapter_0: Array[LevelData] = [
	LevelData.new("Test level", 5, 5, func(l: Level):
		l.add_goal(0, 1, true)
		for i in range(5):
			l.add_bush(2, i)
		l.add_teleport(0, 3)
		l.add_teleport(4, 3)
		l.add_player(4, 4)
		l.add_torch(3, 0)
		l.add_plant(4, 1)
		),
	]

static var chapter_1: Array[LevelData] = [
	LevelData.new("Welcome!", 5, 5, func(l: Level):
		l.add_goal(0, 1)
		l.add_bush(2, 0)
		l.add_bush(2, 1)
		l.add_bush(2, 2)
		l.add_bush(2, 3)
		l.add_player(4, 1)
		),

	LevelData.new("Boxes can be pushed!", 5, 5, func(l: Level):
		l.add_goal(0, 0)
		l.add_bush(4, 1)
		l.add_box(3, 1)
		l.add_box(3, 2)
		l.add_bush(3, 3)
		l.add_box(2, 2)
		l.add_bush(1, 2)
		l.add_bush(1, 3)
		l.add_bush(1, 4)
		l.add_bush(2, 0)
		l.add_player(4, 2)
		),

	LevelData.new("Potted plants can be pushed, too!", 5, 6, func(l: Level):
		l.add_goal(0, 0)
		l.add_tall_bush(0, 3)
		l.add_tall_bush(1, 3)
		l.add_tall_bush(2, 3)
		l.add_plant(3, 3)
		l.add_tall_bush(4, 3)
		l.add_player(2, 5)
		),

	LevelData.new("Is something hiding here?", 5, 5, func(l: Level):
		l.add_goal(1, 2)
		l.add_plant(2, 3)
		l.add_plant(4, 2)
		l.add_player(3, 1),
		),

	LevelData.new("Where did it go?", 5, 5, func(l: Level):
		l.add_goal(0, 3)
		l.add_player(3, 2)
		l.add_bush(0, 1)
		l.add_bush(0, 2)
		l.add_bush(2, 1)
		l.add_bush(2, 2)
		l.add_bush(2, 3)
		l.add_bush(3, 3)
		l.add_bush(4, 3)
		l.add_plant(1, 1),
		),

	LevelData.new("Perspective matters!", 5, 5, func(l: Level):
		l.add_goal(1, 1)
		l.add_tall_bush(2, 2)
		l.add_player(4, 1)
		l.add_rotation_switch(4, 2),
		),

	LevelData.new("What if I can't see it?", 6, 5, func(l: Level):
		l.add_goal(0, 1)
		l.add_player(4, 2)
		for x in 5:
			l.add_bush(3, x)
		l.add_tall_bush(4, 0)
		l.add_tall_bush(1, 0)
		l.add_rotation_switch(0, 4)
		l.add_rotation_switch(5, 4),
		),

	LevelData.new("Magic trick", 6, 5, func(l: Level):
		l.add_player(0, 4)
		l.add_bush(2, 4)
		l.add_bush(2, 3)
		l.add_bush(2, 2)
		l.add_bush(1, 0)
		l.add_bush(2, 0)
		l.add_bush(4, 0)
		l.add_tall_bush(4, 2)
		l.add_box(1, 1)
		l.add_goal(5, 4),
		),

	LevelData.new("Push to hide", 6, 4, func(l: Level):
		l.add_goal(0, 0)
		for y in 6:
			l.add_bush(y, 1)
		l.add_bush(2, 0)
		l.add_plant(4, 2)
		l.add_player(4, 0),
		),

	LevelData.new("A pair of bushes", 5, 5, func(l: Level):
		l.add_goal(0, 4)
		l.add_bush(1, 4)
		l.add_bush(0, 3)
		l.add_plant(2, 2)
		l.add_player(0, 1)
		l.add_rotation_switch(4, 2),
		),

	LevelData.new("Two layers", 7, 5, func(l: Level):
		for i in range(5):
			l.add_bush(1, i)
			l.add_bush(3, i)
		l.add_plant(5, 1)
		l.add_plant(5, 3)
		l.add_goal(0, 2)
		l.add_player(6, 2),
		),

	LevelData.new("To rotate or not to rotate", 4, 5, func(l: Level):
		for i in range(4):
			l.add_bush(i, 3)
		l.add_plant(2, 0)
		l.add_rotation_switch(1, 1)
		l.add_tall_bush(0, 2)
		l.add_goal(2, 4)
		l.add_player(2, 2),
		),
	]

static var chapter_2: Array[LevelData] = [
	LevelData.new("It's getting crowded in here!", 5, 5, func(l: Level):
		l.add_goal(2, 2)
		l.add_bush(2, 3)
		l.add_bush(3, 2)
		l.add_bush(2, 1)
		l.add_bush(1, 2)

		l.add_plant(1, 1)
		l.add_plant(1, 3)
		l.add_plant(3, 1)
		l.add_plant(3, 3)
		l.add_plant(1, 4)

		l.add_player(4, 0)
		l.add_rotation_switch(4, 1),
		),

	LevelData.new("Ramping up the challenge", 5, 5, func(l: Level):
		l.add_goal(0, 4)
		l.add_bush(1, 4)
		l.add_bush(2, 4)
		l.add_bush(0, 3)
		l.add_bush(0, 2)

		l.add_plant(2, 3)
		l.add_plant(2, 2)
		l.add_plant(1, 2)
		l.add_rotation_switch(4, 0)

		l.add_player(4, 4),
		),

	LevelData.new("Palace garden", 7, 7, func(l: Level):
		l.add_plant(3, 5)
		l.add_player(6, 6)
		l.add_rotation_switch(3, 4)
		for i in range(2, 5):
			l.add_bush(i, 3)
		for i in range(0, 4):
			l.add_bush(1, i)
			l.add_bush(5, i)
		l.add_plant(4, 2)
		l.add_plant(2, 2)
		l.add_plant(4, 0)
		l.add_plant(2, 0)
		l.add_goal(3, 1)
		l.add_bush(2, 4)
		l.add_bush(4, 4)
		l.add_bush(1, 5)
		l.add_bush(5, 5),
		),

	LevelData.new("Tall bushes all around", 5, 7, func(l: Level):
		l.add_bush(1, 0)
		l.add_rotation_switch(0, 1)
		l.add_tall_bush(2, 1)
		l.add_tall_bush(4, 1)
		l.add_tall_bush(2, 2)
		l.add_goal(3, 2)
		l.add_tall_bush(0, 3)
		l.add_plant(2, 3)
		l.add_bush(3, 3)
		l.add_tall_bush(4, 3)
		l.add_tall_bush(1, 4)
		l.add_player(3, 4)
		l.add_tall_bush(4, 4)
		l.add_bush(2, 5)
		l.add_bush(0, 6),
		),

	LevelData.new("Too late", 8, 6, func(l: Level):
		l.add_bush(7, 3)
		l.add_goal(7, 4)
		l.add_bush(6, 3)
		l.add_bush(6, 4)
		l.add_bush(6, 5)
		l.add_tall_bush(5, 0)
		for i in range(6):
			l.add_bush(4, i)
		l.add_plant(3, 2)
		l.add_rotation_switch(2, 3)
		l.add_tall_bush(1, 2)
		l.add_plant(1, 4)
		l.add_bush(1, 5)
		l.add_bush(0, 4)
		l.add_player(0, 0),
		),

	LevelData.new("Soko soko", 5, 5, func(l: Level):
		l.add_bush(0, 1)
		l.add_bush(1, 0)
		l.add_goal(0, 0)
		l.add_player(4, 0)
		l.add_plant(3, 1)
		l.add_box(2, 2)
		l.add_box(1, 2)
		l.add_box(2, 1)
		l.add_bush(1, 1)
		l.add_box(3, 0)
		l.add_bush(2, 3)
		l.add_box(3, 3),
		),

	LevelData.new("How do I get out of this?", 5, 5, func(l: Level):
		l.add_bush(2, 4)
		l.add_rotation_switch(4, 3)
		l.add_plant(3, 3)
		l.add_tall_bush(2, 3)
		l.add_tall_bush(0, 3)
		l.add_tall_bush(2, 2)
		l.add_goal(1, 2)
		l.add_bush(4, 1)
		l.add_plant(2, 1)
		l.add_bush(1, 1)
		l.add_tall_bush(0, 1)
		l.add_bush(1, 0)
		l.add_player(0, 4),
		),

	LevelData.new("Don't get stuck!", 9, 9, func(l: Level):
		l.add_goal(0, 0)
		l.add_tall_bush(1,1)

		l.add_rotation_switch(4, 4)

		l.add_box(3,3)
		l.add_box(3,4)
		l.add_box(3,5)

		l.add_box(4,3)
		l.add_box(4,5)

		l.add_box(5,4)

		l.add_bush(5,5)
		l.add_bush(5,2)
		l.add_bush(2,3)
		l.add_bush(2,4)
		l.add_bush(4,2)
		l.add_bush(6,4)
		l.add_bush(6,3)
		l.add_bush(4,6)
		l.add_bush(6,5)

		l.add_plant(6,6)
		l.add_plant(1,7)
		l.add_player(0, 8),
		),
	]

static var chapter_coda: Array[LevelData] = [
	LevelData.new("Game over", 3, 3, func(l: Level):
		l.add_goal(2, 1)
		l.add_box(1, 2)
		l.add_plant(2, 0)
		l.add_rotation_switch(1,0)
		l.add_bush(0, 1)
		l.add_tall_bush(0, 2)
		l.add_player(1, 1)
		l.add_bush(0, 0)
		SignalBus.game_over.emit()
		)]

static var chapters = [chapter_0, chapter_1, chapter_2, chapter_coda]
