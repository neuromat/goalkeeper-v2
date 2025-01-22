class_name PreGame
extends Node

@export var context_trees_root_dir = \
	'res://data'

@onready var context_tree_files_container: ContextTreeFilesContainer = \
	$Control/MarginContainer/HBoxContainer/HBoxContainer/ContextTreeFilesMargin/ContextTreeFilesContainer
@onready var match_options: VBoxContainer = \
	$Control/MarginContainer/HBoxContainer/HBoxContainer/HBoxContainer/MatchOptionsMargin/MatchOptions
@onready var buttons: VBoxContainer = \
	$Control/MarginContainer/HBoxContainer/HBoxContainer/HBoxContainer/ButtonsMargin/Buttons

signal event_bus(event: Dictionary)

func _ready() -> void:
	print_debug('pre-game ready!')
	if _is_root_scene():
		_play_demo()

# public
func start() -> void:
	_setup_context_tree_options()


# private
func _setup_context_tree_options() -> void:
	var file_names = DirAccess.get_files_at(context_trees_root_dir)
	var absolute_file_paths = []
	for f in file_names:
		if f.ends_with('.csv'):
			var file_full_path = "%s/%s" % [ context_trees_root_dir, f ]
			absolute_file_paths.append(file_full_path)
	context_tree_files_container.load_(absolute_file_paths)


# signal handling
func _on_play_pressed() -> void:
	# TODO refactor this: Play should be disabled if no context tree is selected
	#	perhaps add a validation function that gives a visual feedback
	var context_tree_file = \
		context_tree_files_container.get_selected_context_tree_file()
	if context_tree_file == null:
		return
	# TODO refactor and publish the ContextTree itself, not only the path
	#	to avoid instantiating it again in the AI scene
	var event = {
		"action": "PLAY",
		"selected_context_tree_file_path": context_tree_file.absolute_file_path,
		"match_options": _get_match_options()
	}
	_emit_event(event)

func _on_quit_pressed() -> void:
	var event = { "action": "QUIT" }
	_emit_event(event)


# getters
func _get_match_options() -> Dictionary:
	return {
		'n_rounds': _get_n_rounds(),
		'setup_time': _get_setup_time(),
		'feedback_time': _get_feedback_time()
	}

func _get_n_rounds() -> int:
	return roundi((match_options.get_node("NRounds/SpinBox") as SpinBox).value)

func _get_setup_time() -> float:
	return (match_options.get_node("SetupTime/HSliderWithLabel/HSlider") \
		as HSlider).value

func _get_feedback_time() -> float:
	return (match_options.get_node("FeedbackTime/HSliderWithLabel/HSlider") \
		as HSlider).value


# helpers
func _is_root_scene() -> bool:
	return self == get_tree().root.get_child(0)

func _play_demo():
	start()

func _emit_event(event: Dictionary) -> void:
	print_debug(event)
	if _is_root_scene():
		_handle_event_internally(event)
	else:
		event_bus.emit(event)

func _handle_event_internally(event: Dictionary) -> void:
	if event['action'] == 'QUIT':
		get_tree().quit()
