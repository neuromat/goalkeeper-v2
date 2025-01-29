class_name DefaultFilesLoader

const origin_folder_path = 'res://data'
const destination_folder_path = 'user://context_trees'

static func load():
	if not DirAccess.dir_exists_absolute(destination_folder_path):
		var error: Error = DirAccess.make_dir_absolute(destination_folder_path)
		if error:
			# should raise an error message
			print_debug(error)
	var file_names = DirAccess.get_files_at(origin_folder_path)
	for f in file_names:
		if f.ends_with('.csv'):
			var from_path = "%s/%s" % [ origin_folder_path, f ]
			var to_path = "%s/%s" % [ destination_folder_path, f ]
			# var error = DirAccess.copy_absolute(from_path, to_path)
			var error = _copy_absolute(from_path, to_path)
			if error:
				print_debug(error)


static func _copy_absolute(from_path: String, to_path: String) -> Error:
	var origin_file: FileAccess = FileAccess.open(from_path, FileAccess.READ)
	if not origin_file:
		return FileAccess.get_open_error()
	var content = origin_file.get_as_text()
	origin_file.close()
	var destination_file: FileAccess = FileAccess.open(to_path, FileAccess.WRITE)
	if not destination_file:
		return FileAccess.get_open_error()
	destination_file.store_string(content)
	destination_file.close()
	return OK
