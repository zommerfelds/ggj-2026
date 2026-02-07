extends Node
class_name MenuCommon

# Make mouse hover move the focus, to avoid conflicting hover and focus.
static func hover_to_focus(b: Button) -> void:
	b.mouse_entered.connect(func():
		if not b.disabled:
			b.grab_focus.call_deferred())
