extends CharacterBody3D
class_name Player

const speed = 2.5
@export var camera: Camera3D


# While pushing an object: Direction and accumulated time (frames).
var push_direction: Vector3i = Vector3i.ZERO
var push_time: float = 0.0
var current_step_is_left = false
var walking_up = false
var currently_heading_right = false
var time_since_moved = 0.0
var has_won = false
var joystick_direction = Vector2.ZERO
var can_move = true
var has_world_ended = false

var state_history = []

func _ready() -> void:
	%AnimationPlayer.play()
	SignalBus.connect("game_over", game_over)
	SignalBus.connect("joystick_moved", joystick_moved)
	SignalBus.connect("is_camera_rotating", on_is_camera_rotating)
	SignalBus.connect("is_rewinding", on_is_rewinding)
	SignalBus.connect("end_world", end_world)
	SignalBus.connect("un_end_world", on_un_end_world)

func _physics_process(_delta):
	if has_won || !can_move || has_world_ended: return
	# Direction with controller or arrow keys (LR/UD)
	var direction = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_forward", "move_back")).limit_length(1.0)

	if Platform.current_input_device == Platform.InputDevice.KEYBOARD && Settings.diagonal_arrow_keys:
		direction = direction.rotated(-PI / 4.0)

	# Direction with QEAD (diagonal)
	var direction_diag = Vector2(
		Input.get_axis("move_up_left", "move_down_right"),
		Input.get_axis("move_up_right", "move_down_left")).limit_length(1.0)

	if direction_diag.length_squared() > direction.length_squared():
		direction = direction_diag.rotated(PI / 4.0)

	if joystick_direction.length_squared() > direction.length_squared():
		direction = joystick_direction

	direction = direction.rotated(-camera.global_rotation.y)

	var pushing_angle = rad_to_deg(
		Vector3(direction.x, 0, direction.y)
			.angle_to(Vector3(push_direction))
	)
	var is_pushing = push_direction.length() > 0.1 && direction.length() > 0.1 && pushing_angle < 45.1
	if is_pushing:
		direction = Vector2(push_direction.x, push_direction.z)

	if velocity.length() > 0.1:
		var velocity2D = Vector2(velocity.x, velocity.z)
		var screen_direction_velocity = velocity2D.rotated(camera.global_rotation.y)
		walking_up = screen_direction_velocity.dot(Vector2.DOWN) > -0.01
		if screen_direction_velocity.x != 0.0 and absf(screen_direction_velocity.x) > 0.1:
			currently_heading_right = screen_direction_velocity.x > 0.0
	else:
		var screen_direction = direction.rotated(camera.global_rotation.y)
		walking_up = screen_direction.dot(Vector2.DOWN) > -0.01
		if screen_direction.x != 0.0 and absf(screen_direction.x) > 0.1:
			currently_heading_right = screen_direction.x > 0.0

	# Smoothly ramp up/down the velocity.
	const interpolation = 0.3
	velocity.x = 0 if is_pushing else lerp(velocity.x, direction.x * speed, interpolation)
	velocity.z = 0 if is_pushing else lerp(velocity.z, direction.y * speed, interpolation)

	if velocity.length() > 0.01:
		SignalBus.player_moved.emit()

	move_and_slide()
	maybe_push(_delta, direction)

	set_anim_state(direction)


func set_anim_state(direction: Vector2):
	%AnimationPlayer.speed_scale = 1.0
	if has_won:
		%AnimationPlayer.current_animation = "happy"
		return
	if not direction.is_zero_approx():
		if push_time > 0:
			%AnimationPlayer.current_animation = "push" if walking_up else "push_back"
		else:
			var just_switched = false
			if not %AnimationPlayer.current_animation.begins_with("walk"):
				current_step_is_left = not current_step_is_left
				just_switched = true

			%AnimationPlayer.current_animation = "walk" if walking_up else "walk_back"
			%AnimationPlayer.speed_scale = max(velocity.length(), 1.0) * 0.5

			if just_switched and current_step_is_left:
				%AnimationPlayer.seek(0.4) # This is half of the walk cycle...
		%Face.scale.x = 1 if %AnimationPlayer.current_animation.ends_with("back") == currently_heading_right else -1

	elif not %AnimationPlayer.current_animation.begins_with("idle"):
		if %AnimationPlayer.current_animation.ends_with("back"):
			%AnimationPlayer.current_animation = "idle_back"
		else:
			%AnimationPlayer.current_animation = "idle"


func maybe_push(delta: float, direction: Vector2):
	var collisions_count = get_slide_collision_count()
	for i in collisions_count:
		var collision = get_slide_collision(i)
		if collision != null:
			if collision.get_collider() is Goal:
				enter_win_state()
				return

	var c = get_last_slide_collision()
	if c == null:
		push_direction = Vector3i.ZERO
		push_time = 0
		return

	var n = c.get_normal()
	var push_new = Vector3i.ZERO
	var collider_position = (c.get_collider() as Node3D).global_position

	var dirs = [Vector3i(-1, 0, 0), Vector3i(1, 0, 0), Vector3i(0, 0, -1), Vector3i(0, 0, 1)]
	for dir in dirs:
		if n.dot(dir) < -0.8:
			push_new = dir
			break

	var canBePushed = (c.get_collider().has_method("perform_push"))
	var center_distance = global_position.distance_to(collider_position)

	if !canBePushed || center_distance > 0.8:
		push_direction = Vector3i.ZERO
		push_time = 0
		return

	if push_new == push_direction and push_new != Vector3i.ZERO and Vector3(direction.x, 0, direction.y).dot(push_new) > 0.8:
		push_time += delta
		var nextPosition = collider_position + Vector3(push_new)
		if (push_time > 0.5 and isSpaceFree(nextPosition)):
			%AudioStreamPlayer2.play()
			c.get_collider().perform_push(Vector3(push_direction))
			push_time = 0
	else:
		push_time = 0
		push_direction = push_new

func isSpaceFree(global_pos: Vector3) -> bool:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsPointQueryParameters3D.new()
	query.position = global_pos
	var result = space_state.intersect_point(query)
	return result.size() == 0

func enter_win_state():
	if has_won:
		return
	%AudioStreamPlayer.stream = preload("res://sounds/274182__littlerobotsoundfactory__jingle_win_synth_05.wav")
	%AudioStreamPlayer.play()
	has_won = true
	SignalBus.goal_reached.emit()

func game_over():
	has_won = true
	set_anim_state(Vector2(0,0))

func joystick_moved(dir):
	joystick_direction = dir

func on_is_camera_rotating(is_rotating: bool):
	can_move = !is_rotating

func on_is_rewinding(is_rewinding: bool):
	can_move = !is_rewinding
	if !is_rewinding:
		%AnimationPlayer.play()

func end_world(_v: Vector3):
	velocity = Vector3.ZERO
	set_anim_state(Vector2.ZERO)
	has_world_ended = true

func on_un_end_world():
	has_world_ended = false

func save_state():
	state_history.push_back({
		"position": position,
		"current_animation": %AnimationPlayer.current_animation,
		"animation_speed_scale": %AnimationPlayer.speed_scale,
		"current_animation_position": %AnimationPlayer.current_animation_position,
		"current_step_is_left": current_step_is_left,
		"walking_up": walking_up,
		"currently_heading_right": currently_heading_right,
		"face_scale_x": %Face.scale.x,
	})

func load_state():
	%AnimationPlayer.pause()
	var state = state_history.pop_back()
	if state == null:
		return

	position = state["position"]
	%AnimationPlayer.current_animation = state["current_animation"]
	%AnimationPlayer.speed_scale = state["animation_speed_scale"]
	%AnimationPlayer.seek(state["current_animation_position"], true)
	current_step_is_left = state["current_step_is_left"]
	walking_up = state["walking_up"]
	currently_heading_right = state["currently_heading_right"]
	%Face.scale.x = state["face_scale_x"]

	# Always reset timers and push direction
	time_since_moved = 0.0
	push_time = 0.0
	push_direction = Vector3i.ZERO
