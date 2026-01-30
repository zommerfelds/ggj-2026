extends Node2D


var direction = Vector2(2, 2)


func _physics_process(_delta: float) -> void:
	var controller = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")).limit_length(0.4)

	testing what happens when checking in broken code.

	direction = (direction + controller).limit_length(10.0)
	$Label.position += direction
	if $Label.position.x > get_viewport_rect().end.x - $Label.size.x:
		direction.x = -abs(direction.x)
	if $Label.position.x < 0:
		direction.x = abs(direction.x)
	if $Label.position.y > get_viewport_rect().end.y - $Label.size.y:
		direction.y = -abs(direction.y)
	if $Label.position.y < 0:
		direction.y = abs(direction.y)
