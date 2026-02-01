@tool
extends Control



var direction = Vector2.ZERO
var angle = 0.0
var grabbed = false
var touch_index = -1
var touch_start = Vector2.ZERO


const WHITEISH = Color(0, 0, 0, 0.2)
const GRABBED_COLOR = Color(0, 0, 0, 0.4)


func _draw():
	var center = size / 2
	var r = size.x / 2
	draw_circle(center, r, WHITEISH, false, 4.0, true)

	const LINE_WIDTH = 4.0
	var pad_center = center + direction * r * 0.8

	draw_circle(pad_center, r / 2 + LINE_WIDTH / 2, GRABBED_COLOR if grabbed else WHITEISH, true, -1.0, true)
	draw_circle(pad_center, r / 2, WHITEISH, false, LINE_WIDTH, true)


func _input(event):
	if event is InputEventScreenTouch:
		handle_touch(event)
	elif event is InputEventScreenDrag:
		handle_drag(event)


func handle_touch(event : InputEventScreenTouch) -> void:
	if event.pressed:
		if grabbed: return

		var dist = (event.position - position - size / 2).length()
		if dist > size.x * 1.5: return

		grabbed = true
		touch_index = event.index
		touch_start = event.position
		queue_redraw()
		get_viewport().set_input_as_handled()
		SignalBus.joystick_moved.emit(direction)
	else:  # released
		if grabbed and event.index == touch_index:
			grabbed = false
			touch_index = -1
			direction = Vector2.ZERO
			queue_redraw()
			get_viewport().set_input_as_handled()
			SignalBus.joystick_moved.emit(direction)


func handle_drag(event : InputEventScreenDrag) -> void:
	if not grabbed or event.index != touch_index:
		return

	var r = size.x / 2

	var delta = event.position - touch_start
	direction = delta / r
	if direction.length_squared() > 1.0:
		direction = direction.normalized()

	queue_redraw()
	get_viewport().set_input_as_handled()
	SignalBus.joystick_moved.emit(direction)
