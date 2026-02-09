extends Object
class_name FileIO


# Prints error message and returns empty dictionary on error.
static func read_json_dict(path) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}

	var settings_file = FileAccess.open(path, FileAccess.READ)
	if settings_file == null:
		printerr("File read open error: ", FileAccess.get_open_error())
		return {}

	var json_string = settings_file.get_line()
	var json = JSON.new()

	if json.parse(json_string) != OK:
		printerr("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return {}

	return json.data


# Prints error message on error.
static func save_json_dict(path: String, data: Dictionary) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		printerr("File write open error: ", FileAccess.get_open_error())
		return

	var success = file.store_line(JSON.stringify(data))
	if not success:
		printerr("Failed to store %s" % path)
