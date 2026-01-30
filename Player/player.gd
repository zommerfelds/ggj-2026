extends CharacterBody3D

@export var speed = 6
@export var camera: Camera3D

func _physics_process(delta):
	var direction = Vector3.ZERO

	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
		
	direction = direction.normalized().rotated(Vector3.UP, camera.global_rotation.y)
	
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	move_and_slide()
