class_name ContextTreeFilesContainer
extends VBoxContainer

signal selected(index: int)

@onready var items_list: ItemListWithInfoOnRight = $ItemListWithInfosOnRight

var absolute_file_paths: Array
var selected_context_tree_idx: int = -1
var context_tree_files: Array = []

func _ready() -> void:
	reset()
	if _is_root_scene():
		_play_demo()


func _is_root_scene() -> bool:
	return self == get_tree().root.get_child(0)

func _play_demo():
	load_()


func load_() -> void:
	_load_absolute_file_paths()
	var data = []
	for f in absolute_file_paths:
		data.append(
			_load_context_tree_file(f as String))
	items_list.load_(data)

func get_selected_context_tree_file() -> ContextTreeFile:
	if selected_context_tree_idx == -1:
		return null
	return context_tree_files[selected_context_tree_idx]

func reset() -> void:
	items_list.reset()
	absolute_file_paths = []
	selected_context_tree_idx = -1
	context_tree_files = []


func _load_context_tree_file(absolute_file_path: String) -> Dictionary:
	var relative_file_path = absolute_file_path.split('/')[-1]
	var context_tree_file = ContextTreeFile.new(absolute_file_path)
	var errors = context_tree_file.parser_result['errors']
	var info: String
	if context_tree_file.is_valid:
		info = 'The file is OK!'
	else:
		info = '\n'.join(errors)
	context_tree_files.append(context_tree_file)
	return {
		'text': relative_file_path,
		'info': info
	}

func _load_absolute_file_paths() -> void:
	var file_names = DirAccess.get_files_at(DefaultFilesLoader.destination_folder_path)
	for f in file_names:
		if f.ends_with('.csv'):
			var file_full_path = "%s/%s" % [ DefaultFilesLoader.destination_folder_path, f ]
			absolute_file_paths.append(file_full_path)

# signal handling
func _on_item_list_selected(index: int) -> void:
	var context_tree_file = context_tree_files[index] as ContextTreeFile
	if context_tree_file.is_valid:
		selected_context_tree_idx = index
		selected.emit(selected_context_tree_idx)
	else:
		selected_context_tree_idx = -1

func _on_refresh_pressed() -> void:
	reset()
	load_()
