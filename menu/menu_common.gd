extends Node
class_name MenuCommon

static var _theme_without_focus: Theme = null


# Make mouse hover move the focus, to avoid conflicting hover and focus.
static func hover_to_focus(b: Button) -> void:
	b.mouse_entered.connect(func():
		if not b.disabled:
			b.grab_focus.call_deferred())


# For touch screens, the focus ring stays after pressing a button which just
# looks weird.
static func theme_without_focus() -> Theme:
	if _theme_without_focus == null:
		_theme_without_focus = preload("res://menu/menu_theme.tres").duplicate(true)
		var empty = StyleBoxEmpty.new()
		for control in ["Button", "CheckBox"]:
			_theme_without_focus.set_stylebox("focus", control, empty)

	return _theme_without_focus
