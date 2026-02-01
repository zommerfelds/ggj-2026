@tool
extends Control

@export var action_name: String = "touch_button"
var touch_index = -1


const WHITEISH = Color(0, 0, 0, 0.2)
const LINE_WIDTH = 4.0


func _draw():
	var center = size / 2
	var r = size.x / 2
	draw_circle(center, r, WHITEISH, false, LINE_WIDTH, true)
	if Input.is_action_pressed(action_name):
		draw_circle(center, r + LINE_WIDTH / 2, WHITEISH, true, -1.0, true)


func _input(event):
	if event is InputEventScreenTouch:
		handle_touch(event)
	elif event is InputEventScreenDrag:
		handle_drag(event)
	queue_redraw()


func handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		var dist = (event.position - position - size / 2).length()
		if dist > size.x * 0.5: return

		touch_index = event.index
		get_viewport().set_input_as_handled()
		Input.action_press(action_name)
	else:  # released
		if Input.is_action_pressed(action_name) and (event.index == touch_index or touch_index == -1):
			touch_index = -1
			get_viewport().set_input_as_handled()
			Input.action_release(action_name)


func handle_drag(_event: InputEventScreenDrag) -> void:
	pass  # TODO - release button?
