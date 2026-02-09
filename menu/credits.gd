extends Control


var page = 0
var base_font_size = 80


func _ready() -> void:
	for b in $Buttons.get_children():
		MenuCommon.hover_to_focus(b)
	update_text()
	get_viewport().size_changed.connect(update_layout)
	update_layout()


func update_layout() -> void:
	var vp_size = get_viewport().get_visible_rect().size
	var rel_scale = min(vp_size.x, vp_size.y) / 1200
	%Text.add_theme_font_size_override("font_size", rel_scale * base_font_size)
	%Title.add_theme_font_size_override("font_size", rel_scale * 100)
	%Title.position.y = rel_scale * 80
	%Title.size = Vector2(vp_size.x, rel_scale * 100)
	%Text.position = Vector2(10, rel_scale * 250)
	%Text.size = Vector2(vp_size.x - 20, vp_size.y - %Text.position.y)
	# 0.5 is roughly where buttons span the width
	if rel_scale < 0.5:
		$Buttons.scale = Vector2(rel_scale / 0.5, rel_scale / 0.5)
	pass

func update_text() -> void:
	base_font_size = 80 if page == 0 else 24
	update_layout()

	match page % 3:
		0:
			var full_time = [ "Christian Zommerfelds", "Björn Carlin", "Valentin Schlattinger" ]
			var part_time = [ "Yue Li" ]
			full_time.shuffle()
			part_time.shuffle()
			%Text.text = "Developed by\n" + "\n".join(full_time + part_time)
			%Text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		1:
			%Text.text = "Using the Godot Engine:\n\n" + Engine.get_license_text()
			%Text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		2:
			var misc = [
				"PromptFont by Yukari \"Shinmera\" Hafner, available at https://shinmera.com/promptfont",
				"swoosh26.wav by kwahmah_02 -- https://freesound.org/s/269288/ -- License: Attribution 3.0",
				"Jingle_Win_Synth_05.wav by LittleRobotSoundFactory -- https://freesound.org/s/274182/ -- License: Attribution 4.0",
				"Low_Swoosh - 7.wav by SoundFlakes -- https://freesound.org/s/416478/ -- License: Attribution 4.0",
				"Grass Step Left by spycrah -- https://freesound.org/s/535220/ -- License: Attribution 4.0",
				"Furniture - Drawers open & close by Vrymaa -- https://freesound.org/s/802695/ -- License: Creative Commons 0",
				# Note: I'll likely replace these icons with my own, but for now putting this:
				"Icon: home by counloucon from Noun Project -- License: CC BY 3.0",
				"Icon: rotate by Dwi ridwanto from Noun Project -- License: CC BY 3.0",
				"Icon: next by Acharyas from Noun Project -- License: CC BY 3.0",
			]

			%Text.text = "Also using:\n\n" + "\n\n".join(misc)
			%Text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	if page > 6:
		%Debug.visible = true


func _on_next_pressed() -> void:
	page += 1
	update_text()


func _on_ok_pressed() -> void:
	SignalBus.change_screen.emit(SignalBus.Screen.MENU)


func _on_visibility_changed() -> void:
	if visible and Platform.current_input_device != Platform.InputDevice.TOUCH:
		%OK.grab_focus.call_deferred()


func _on_debug_pressed() -> void:
	Settings.debug_mode = !Settings.debug_mode
	%Debug.text = "Disable debug" if Settings.debug_mode else "Enable debug"
