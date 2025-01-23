class_name ContextTreeFile

var context_tree: ContextTree
var absolute_file_path: String
var parser_result: Dictionary
var is_valid: bool

func _init(absolute_file_path_: String) -> void:
	absolute_file_path = absolute_file_path_
	context_tree = ContextTree.new()
	parser_result = context_tree.initialize(absolute_file_path)
	is_valid = (parser_result['errors'] as Array).size() == 0
