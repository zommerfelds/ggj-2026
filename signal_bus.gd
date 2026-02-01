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
