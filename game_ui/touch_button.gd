@tool
extends Control

const LINE_WIDTH = 4.0
const BLACK = Color(0, 0, 0, 0.2)
const WHITE = Color(1, 1, 1, 0.2)

# TouchButton supports two modes depending on the desired button behavior:

# action_name is the action that will be "pressed" as long as the touch-gesture is active.
# Calls "Input.action_press()" when pressed.
@export var action_name: String = ""

# event_action is an action that will be issued once if the touch-gesture is "released" within
# the button bounds. Calls "Input.parse_input_event()" when released.
@export var event_action: String = ""

var touch_index = -1
var disabled = false
# Whether the current drag gesture is staying inside the button
var drag_inside: bool = false

var color = BLACK


func _draw():
	var center = size / 2
	var r = size.x / 2
	draw_circle(center, r, color, false, LINE_WIDTH, true)

	# touch_button is @tool-enabled for drawing but accessing actions will result in error messages.
	if Engine.is_editor_hint():
		return

	if touch_index >= 0 and drag_inside:
		draw_circle(center, r + LINE_WIDTH / 2, color, true, -1.0, true)


func _input(event):
	# touch_button is @tool-enabled for drawing but accessing actions will result in error messages.
	if Engine.is_editor_hint():
		return

	if event is InputEventScreenTouch:
		handle_touch(event)
	elif event is InputEventScreenDrag:
		handle_drag(event)
	queue_redraw()


func set_inverted(inverted: bool) -> void:
	color = WHITE if inverted else BLACK
	queue_redraw()


func set_texture(t: Texture, flip_h: bool = false) -> void:
	if t == null:
		$TextureRect.visible = false
	else:
		$TextureRect.texture = t
		$TextureRect.visible = true
		if flip_h:
			$TextureRect.scale = Vector2(-1, 1)
	$TextureRect.size = size - Vector2(20, 20)


func set_disabled(new_value: bool) -> void:
	disabled = new_value


func handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed and not disabled:
		var dist = (event.position - position - size / 2).length()
		if dist > size.x * 0.5: return

		touch_index = event.index
		get_viewport().set_input_as_handled()
		if !action_name.is_empty():
			Input.action_press(action_name)
		drag_inside = true
	elif event.index == touch_index:  # released
		if !action_name.is_empty():
			# We allow *releasing* while disabled to avoid the action getting stuck as "pressed"
			# when the pressing causes the button to become disabled... Hopefully there are no
			# really weird corner cases where this goes wrong?
			if Input.is_action_pressed(action_name) and (event.index == touch_index or touch_index == -1):
				Input.action_release(action_name)
		else:
			# Event action on release
			if drag_inside and not disabled:
				var action = InputEventAction.new()
				action.action = event_action
				action.pressed = true
				Input.parse_input_event(action)

		touch_index = -1
		get_viewport().set_input_as_handled()
	queue_redraw()


func handle_drag(event: InputEventScreenDrag) -> void:
	if event.index != touch_index:
		return # Drag didn't start inside button.

	var dist = (event.position - position - size / 2).length()
	var inside = dist <= size.x * 0.5
	if drag_inside != inside:
		drag_inside = inside
		queue_redraw()
