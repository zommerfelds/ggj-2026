extends StaticBody3D
class_name PushableObject

var prev_position = Vector3()
var target_position = Vector3()
var tween: Tween

var state_history = []

func _init() -> void:
	SignalBus.connect("is_rewinding", on_is_rewinding)

func _ready() -> void:
	prev_position = position
	target_position = position

func perform_push(push_direction: Vector3):
	if tween != null:
		return
	position = prev_position
	target_position = position + push_direction
	tween = get_tree().create_tween()
	tween.tween_property(
		self,
		"position",
		target_position,
		0.3
	)
	await tween.finished
	prev_position = target_position
	tween = null

func on_is_rewinding(is_rewinding: bool):
	if is_rewinding && tween != null:
		tween.kill()
		tween = null
	if !is_rewinding && prev_position != target_position:
		perform_push(target_position - prev_position)
		if state_history.size() > 0:
			var tween_elapsed_time = state_history.back()["tween_elapsed_time"]
			tween.custom_step(tween_elapsed_time)

func save_state():
	var tween_elapsed_time = 0.0
	if tween != null:
		tween_elapsed_time = tween.get_total_elapsed_time()
	state_history.push_back({
		"position": position,
		"prev_position": prev_position,
		"target_position": target_position,
		"tween_elapsed_time": tween_elapsed_time,
	})

func load_state():
	var state = state_history.pop_back()
	if state == null:
		return

	position = state["position"]
	prev_position = state["prev_position"]
	target_position = state["target_position"]
