extends Control


func _ready() -> void:
	# Make mouse hover move the focus so hovering works the same as keyboard/controller focus moves:
	for b in $VBox/Buttons.get_children():
		MenuCommon.hover_to_focus(b)

	visibility_changed.connect(update_state)
	get_viewport().size_changed.connect(update_layout)

	update_state()
	update_layout()


func update_layout() -> void:
	var s = get_viewport().get_visible_rect().size
	var bscale = min(s.x / 800 * 2, s.y / 1200)
	$VBox.scale = Vector2(bscale, bscale)
	var scaled_size = $VBox.size * bscale
	$VBox.position = Vector2(max(0, (s.x - scaled_size.x) / 2), max(0, (s.y - scaled_size.y) / 3))


func _on_visibility_changed() -> void:
	if visible and Platform.current_input_device != Platform.InputDevice.TOUCH:
		%Confirm.grab_focus.call_deferred()


func _on_sound_pressed() -> void:
	Platform.set_sound_enabled(not Platform.sound_enabled)
	update_state()


func update_state() -> void:
	%Sound.text = "Sound: ON" if Platform.sound_enabled else "Sound: OFF"


func _on_confirm_pressed() -> void:
	SignalBus.change_screen.emit("menu")
