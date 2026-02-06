@tool
extends EditorPlugin

var toolbar

func _enter_tree() -> void:
	toolbar = preload("uid://cds33iaqmh7nm").instantiate()
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, toolbar)
	print("enter")

func _exit_tree() -> void:
	print("exit")
	remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, toolbar)
	toolbar.queue_free()
