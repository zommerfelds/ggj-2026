extends Node


enum InputDevice {
	KEYBOARD,
	CONTROLLER,
	XBOX,
	PLAYSTATION,
	TOUCH
}

var is_touch_device = false # Set once during startup
var current_input_device: InputDevice = InputDevice.KEYBOARD # Can change while running


func _init() -> void:
	init_is_touch_device()
	detect_input_device()
	Input.joy_connection_changed.connect(detect_input_device.unbind(2))


func init_is_touch_device():
	is_touch_device = LevelSelector.get_res().touch_ui_enabled || OS.get_name() == "Android" || OS.get_name() == "iOS"

	var window = JavaScriptBridge.get_interface("window")
	if window:
		var js_return = JavaScriptBridge.eval("(('ontouchstart' in window) || (navigator.MaxTouchPoints > 0) || (navigator.msMaxTouchPoints > 0));")
		is_touch_device = js_return == 1


func detect_input_device():
	var device_name = Input.get_joy_name(0)
	if show_touch_ui():
		current_input_device = InputDevice.TOUCH
	elif (device_name.contains("PS3")
			|| device_name.contains("PS4")
			|| device_name.contains("PS5")
			|| device_name.contains("DualSense")):
		current_input_device = InputDevice.PLAYSTATION
	elif (device_name.contains("Xbox") || device_name.contains("XInput")):
		current_input_device = InputDevice.XBOX
	elif (device_name.contains("Controller")
			|| device_name.contains("Gamepad")
			|| device_name.contains("Joy-Con")
			|| device_name.contains("Joy Con")):
		current_input_device = InputDevice.CONTROLLER
	else:
		current_input_device = InputDevice.KEYBOARD


func any_controller() -> bool:
	return (current_input_device == InputDevice.PLAYSTATION or
		current_input_device == InputDevice.XBOX or
		current_input_device == InputDevice.CONTROLLER)


func show_touch_ui() -> bool:
	return Settings.always_show_touch_ui || is_touch_device
