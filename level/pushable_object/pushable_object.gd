extends StaticBody3D
class_name PushableObject

var tween: Tween

var state_history = []

func perform_push(push_direction: Vector3):
	if tween != null:
		return
	tween = get_tree().create_tween()
	tween.tween_property(
		self,
		"position",
		position + push_direction,
		0.3
	)
	await tween.finished
	tween = null

func is_interruptible() -> bool:
	return (
		tween == null &&
		(
			state_history.is_empty() ||
			state_history.back()["is_interruptible"]
		)
	)

func save_state():
	state_history.push_back({
		"position": position,
		"is_interruptible": tween == null,
	})

func load_state():
	var state = state_history.pop_back()
	if state != null:
		position = state["position"]
