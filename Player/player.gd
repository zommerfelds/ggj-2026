extends CharacterBody3D
class_name Player

@export var speed = 4
@export var camera: Camera3D


# While pushing an object: Direction and accumulated time (frames).
var push_direction: Vector3i = Vector3i.ZERO
var push_time: float = 0.0
var current_step_is_left = false
var walking_up = false
var currently_heading_right = false
var time_since_moved = 0.0

func _ready() -> void:
	%AnimationPlayer.play()

func _physics_process(_delta):
	# Direction with controller or arrow keys (LR/UD)
	var direction = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_forward", "move_back")).limit_length(1.0)
	# Direction with QEAD (diagonal)
	var direction_diag = Vector2(
		Input.get_axis("move_up_left", "move_down_right"),
		Input.get_axis("move_up_right", "move_down_left")).limit_length(1.0)

	if direction_diag.length_squared() > direction.length_squared():
		direction = direction_diag.rotated(PI / 4.0)

	walking_up = direction.dot(Vector2.DOWN) > -0.1
	if direction.x != 0.0 and absf(direction.x) > 0.1:
		currently_heading_right = direction.x > 0.0

	direction = direction.rotated(-camera.global_rotation.y)


	var direction3D = Vector3(direction.x, 0, direction.y)
	if (direction3D - Vector3(push_direction)).length() < 0.3:
		direction = Vector2(push_direction.x, push_direction.z)

	# Smoothly ramp up/down the velocity.
	const interpolation = 0.3
	velocity.x = lerp(velocity.x, direction.x * speed, interpolation)
	velocity.z = lerp(velocity.z, direction.y * speed, interpolation)

	if velocity.length() > 0.01:
		SignalBus.player_moved.emit()

	move_and_slide()
	maybe_push(_delta, direction)

	set_anim_state(direction)

func set_anim_state(direction: Vector2):
	%AnimationPlayer.speed_scale = 1.0
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
	var c = get_last_slide_collision()
	if c != null:
		if c.get_collider() is Goal:
			SignalBus.goal_reached.emit()
			return

		var n = c.get_normal()
		var push_new = Vector3i.ZERO

		var dirs = [Vector3i(-1, 0, 0), Vector3i(1, 0, 0), Vector3i(0, 0, -1), Vector3i(0, 0, 1)]
		for dir in dirs:
			if n.dot(dir) < -0.8:
				push_new = dir
				break

		var nextPosition = (c.get_collider() as Node3D).global_position + Vector3(push_new)

		if push_new == push_direction and push_new != Vector3i.ZERO and Vector3(direction.x, 0, direction.y).dot(push_new) > 0.8:
			push_time += delta
			if (push_time > 0.2 and
					(c.get_collider() is Plant or c.get_collider() is Box) and
					isSpaceFree(nextPosition)):
				var tween = get_tree().create_tween()
				tween.tween_property(
					c.get_collider(),
					"position",
					c.get_collider().position + Vector3(push_direction),
					0.3
				)
				push_time = 0
		else:
			push_time = 0
			push_direction = push_new
	else:
		push_time = 0


func isSpaceFree(global_pos: Vector3) -> bool:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsPointQueryParameters3D.new()
	query.position = global_pos
	var result = space_state.intersect_point(query)
	return result.size() == 0
