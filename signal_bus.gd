extends Node


# Emitted when the player touches the goal.
signal goal_reached()

# Whether the screen rotation is enabled.
signal can_rotate(bool)

# End the world. Param denotes the source of the end.
signal end_world(Vector3)

# Emitted when the player moves.
signal player_moved()

# Emitted when the camera is rotated.
signal camera_rotated()

# When the player has completed the final level
signal game_over()

# Emitted when touch joystick moved.
signal joystick_moved(Vector2)

# Emitted when the camera starts or stops rotating
signal is_camera_rotating(bool)

# Emitted when the game starts or stops rewinding
signal is_rewinding(bool)
