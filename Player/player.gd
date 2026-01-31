extends CharacterBody3D
class_name Player

@export var speed = 4
@export var camera: Camera3D


# While pushing an object: Direction and accumulated time (frames).
var push_direction: Vector3i = Vector3i.ZERO
var push_time: float = 0.0
var current_step_is_left = false


func _ready() -> void:
	%AnimationPlayer.play()

func _physics_process(_delta):
	var direction = Vector3.ZERO

	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1

	if direction.x != 0.0:
		%Face.scale.x = -signf(direction.x)
		
	if not direction.is_zero_approx():
		var just_switched = false
		if %AnimationPlayer.current_animation != "walk":
			current_step_is_left = not current_step_is_left
			just_switched = true

		%AnimationPlayer.current_animation = "walk"
		
		if just_switched and current_step_is_left:
			%AnimationPlayer.get_animation()
			%AnimationPlayer.seek(0.4) # This is half of the walk cycle...

	else:
		%AnimationPlayer.current_animation = "idle"

	direction = direction.normalized().rotated(Vector3.UP, camera.global_rotation.y)

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	move_and_slide()
	maybe_push(_delta, direction)

func maybe_push(delta: float, direction: Vector3):
	var c = get_last_slide_collision()
	if c != null and (c.get_collider() is Plant or c.get_collider() is Box):
		var n = c.get_normal()
		var push_new = Vector3i.ZERO

		if n.x > 0.99 && direction.x < -0.99:
			push_new = Vector3i(-1, 0, 0)
		elif n.x < -0.99 && direction.x > 0.99:
			push_new = Vector3i(1, 0, 0)
		elif n.z > 0.99 && direction.z < -0.99:
			push_new = Vector3i(0, 0, -1)
		elif n.z < -0.99 && direction.z > 0.99:
			push_new = Vector3i(0, 0, 1)

		var nextPosition = (c.get_collider() as Node3D).global_position + Vector3(push_new)
		if (!isSpaceFree(nextPosition)):
			push_time = 0
		else:
			if push_new == push_direction:
				push_time += delta
				if push_time > 0.4:
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
