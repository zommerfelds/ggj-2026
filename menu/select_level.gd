extends Control


var base_button_size
@onready var default_button = %Chapter1

# Last mouse motion. Used to distinguish focus moves from mouse-hover versus
# keyboard/controller since only the latter should cause automatic scrolling.
var using_mouse_frame = 0
var current_chapter = 1


func _ready() -> void:
	base_button_size = theme.get_font_size("font_size", "Button")
	theme = theme.duplicate()

	MenuCommon.hover_to_focus(%Chapter1)
	MenuCommon.hover_to_focus(%Chapter2)
	MenuCommon.hover_to_focus(%Back)

	get_viewport().size_changed.connect(update_layout)
	update_layout()

	visibility_changed.connect(update_state)
	update_state()


func update_state() -> void:
	_on_chapter_1_pressed()
	if visible and !Platform.is_touch_device and !default_button.has_focus():
		default_button.grab_focus.call_deferred()


func update_list() -> void:
	for child in %Levels.get_children():
		%Levels.remove_child(child)
		child.queue_free()

	for i in 2:  # Hacky top padding
		%Levels.add_child(Label.new())

	var levels = Level.chapters[current_chapter]
	for i in levels.size():
		var level = levels[i]
		var b = Button.new()
		b.text = "%d: %s" % [i + 1, level.name]
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.pressed.connect(level_selected.bind(i))
		%Levels.add_child(b)
		MenuCommon.hover_to_focus(b)
		if i == 0:
			default_button = b
	for i in 3:  # Hacky bottom padding
		%Levels.add_child(Label.new())

	# To avoid the focus item being hidden by the faded rects, scroll to the
	# next-over neighbors in both directions when gaining focus.
	for i in range(2, %Levels.get_child_count() - 3):
		%Levels.get_child(i).focus_entered.connect(scroll_later.bind(%Levels.get_child(i-2), %Levels.get_child(i+2)))


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		using_mouse_frame = Engine.get_frames_drawn()


# Hack to avoid scrolling before the list is done with layout? TODO: investigate
# if there's a less hacky solution.
func scroll_later(a, b):
	call_deferred("scroll_to", a, b)


func scroll_to(a: Control, b: Control):
	# Only scroll when using keyboard/controller, not mouse
	if using_mouse_frame < Engine.get_frames_drawn() - 20:
		%ScrollContainer.ensure_control_visible(a)
		%ScrollContainer.ensure_control_visible(b)
		%ScrollContainer.scroll_horizontal = 0


func update_layout() -> void:
	var s = get_viewport().get_visible_rect().size
	var ui_scale = clamp(min(s.x, s.y) / 1200, 0.5, 2.0)
	theme.set_font_size("font_size", "Button", base_button_size * ui_scale)
	theme.set_font_size("font_size", "Label", base_button_size * ui_scale)

	if s.x < s.y: # Taller than wide: collapse side bar
		%Chapter1.text = "1"
		%Chapter2.text = "2"
		%Back.text = "<"
		%SidewaysChapter.visible = true
	else:
		%Chapter1.text = "Chapter 1"
		%Chapter2.text = "Chapter 2"
		%Back.text = "Back"
		%SidewaysChapter.visible = false

	%FadeTop.custom_minimum_size.y = 150 * ui_scale
	%FadeBottom.custom_minimum_size.y = 150 * ui_scale


func level_selected(index: int):
	SignalBus.select_level.emit(current_chapter, index)
	SignalBus.change_screen.emit(SignalBus.Screen.GAME)


func _on_back_pressed() -> void:
	SignalBus.change_screen.emit(SignalBus.Screen.MENU)


func _on_chapter_1_pressed() -> void:
	%Chapter1.button_pressed = true
	%Chapter2.button_pressed = false
	current_chapter = 1
	update_list()


func _on_chapter_2_pressed() -> void:
	%Chapter1.button_pressed = false
	%Chapter2.button_pressed = true
	current_chapter = 2
	update_list()
