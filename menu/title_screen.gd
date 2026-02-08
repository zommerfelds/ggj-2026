extends Control



func _ready() -> void:
	for b in $VBox/Buttons.get_children():
		MenuCommon.hover_to_focus(b)
	get_viewport().size_changed.connect(update_layout)
	update_layout()


func _on_visibility_changed() -> void:
	if visible and Platform.current_input_device != Platform.InputDevice.TOUCH:
		%Play.grab_focus.call_deferred()


func _on_play_pressed() -> void:
	SignalBus.change_screen.emit(SignalBus.Screen.GAME)


func _on_select_level_pressed() -> void:
	SignalBus.change_screen.emit(SignalBus.Screen.SELECT_LEVEL)


func _on_settings_pressed() -> void:
	SignalBus.change_screen.emit(SignalBus.Screen.SETTINGS)


func _on_credits_pressed() -> void:
	SignalBus.change_screen.emit(SignalBus.Screen.CREDITS)


func update_layout() -> void:
	var s = get_viewport().get_visible_rect().size
	if s.x > s.y: # Wide
		# Raccoon on right half of screen.
		var rs = min(s.x / 2 / $Raccoon.texture.get_size().x, s.y / $Raccoon.texture.get_size().y)
		$Raccoon.size = $Raccoon.texture.get_size() * rs
		$Raccoon.position = Vector2(s.x / 2, max(0, (s.y - $Raccoon.size.y) / 2))
		$Raccoon.visible = true

		# Button box on left
		var bscale = min(s.x / 1920, s.y / 1200)
		$VBox.scale = Vector2(bscale, bscale)
		var scaled_size = $VBox.size * bscale
		$VBox.position = Vector2(s.x * 0.5 - scaled_size.x, max(0, (s.y - scaled_size.y) / 2))
	else: # Tall
		# TODO: Maybe show smaller raccoon somewhere? For now we just hide it.
		$Raccoon.visible = false

		# Button box centered
		var bscale = min(s.x / 1920 * 2, s.y / 1200)
		$VBox.scale = Vector2(bscale, bscale)
		var scaled_size = $VBox.size * bscale
		$VBox.position = Vector2(max(0, (s.x - scaled_size.x) / 2), max(0, (s.y - scaled_size.y) / 2))
