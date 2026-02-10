extends Control


func _ready() -> void:
	if Platform.show_touch_ui():
		theme = MenuCommon.theme_without_focus()

	# Make mouse hover move the focus so hovering works the same as keyboard/controller focus moves:
	for b in %Checkboxes.get_children():
		if b is Button:
			MenuCommon.hover_to_focus(b)

	visibility_changed.connect(update_state)
	get_viewport().size_changed.connect(update_layout)

	update_state()
	update_layout()


func update_layout() -> void:
	var vp_size = get_viewport().get_visible_rect().size
	var custom_scale = min(vp_size.x / 1200, vp_size.y / 1200)
	%Title.scale = Vector2(custom_scale, custom_scale)
	%Checkboxes.scale = Vector2(custom_scale, custom_scale)
	%OK.scale = Vector2(custom_scale, custom_scale)
	for margin in ["margin_top", "margin_left", "margin_bottom", "margin_right"]:
		$MarginContainer.add_theme_constant_override(margin, 100 * custom_scale)


func _on_visibility_changed() -> void:
	if visible and Platform.current_input_device != Platform.InputDevice.TOUCH:
		%OK.grab_focus.call_deferred()
	update_state()


func update_state() -> void:
	%Sound.set_pressed_no_signal(Settings.sound_enabled)
	%DiagonalArrows.set_pressed_no_signal(Settings.diagonal_arrow_keys)
	%TouchUI.set_pressed_no_signal(Settings.always_show_touch_ui)
	%AlwaysRotation.set_pressed_no_signal(Settings.always_allow_rotation)

	%TouchUI.visible = Settings.debug_mode
	%AlwaysRotation.visible = Settings.debug_mode


func _on_ok_pressed() -> void:
	SignalBus.change_screen.emit(SignalBus.Screen.MENU)


func _on_sound_toggled(toggled_on: bool) -> void:
	Settings.sound_enabled = toggled_on


func _on_diagonal_arrows_toggled(toggled_on: bool) -> void:
	Settings.diagonal_arrow_keys = toggled_on


func _on_touch_ui_toggled(toggled_on: bool) -> void:
	Settings.always_show_touch_ui = toggled_on


func _on_always_rotation_toggled(toggled_on: bool) -> void:
	Settings.always_allow_rotation = toggled_on
