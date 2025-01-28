class_name PreGame
extends Node

@onready var context_tree_files_container: ContextTreeFilesContainer = \
	$Control/MarginContainer/HBoxContainer/HBoxContainer/ContextTreeFilesMargin/ContextTreeFilesContainer
@onready var match_options: VBoxContainer = \
	$Control/MarginContainer/HBoxContainer/HBoxContainer/HBoxContainer/MatchOptionsMargin/MatchOptions
@onready var buttons: VBoxContainer = \
	$Control/MarginContainer/HBoxContainer/HBoxContainer/HBoxContainer/ButtonsMargin/Buttons

signal event_bus(event: PreGameEvent)

func _ready() -> void:
	if _is_root_scene():
		_play_demo()


# public
func start() -> void:
	_setup_context_tree_options()


# private
func _setup_context_tree_options() -> void:
	context_tree_files_container.load_()


# signal handling
func _on_play_pressed() -> void:
	var context_tree_file = \
		context_tree_files_container.get_selected_context_tree_file()
	if context_tree_file == null:
		return
	var event = PreGameEvent.new(
		PreGameEvent.START_MATCH,
		MatchOptions.new(
			context_tree_file.absolute_file_path,
			_get_n_rounds(),
			_get_readiness_time_in_s(),
			_get_feedback_time_in_s()
		)
	)
	_emit_event(event)

func _on_quit_pressed() -> void:
	var event = PreGameEvent.new(PreGameEvent.QUIT_GAME)
	_emit_event(event)


# getters
func _get_n_rounds() -> int:
	return roundi((match_options.get_node("NRounds/SpinBox") \
		as SpinBox).value)

func _get_readiness_time_in_s() -> float:
	return (match_options.get_node("SetupTime/HSliderWithLabel/HSlider") \
		as HSlider).value

func _get_feedback_time_in_s() -> float:
	return (match_options.get_node("FeedbackTime/HSliderWithLabel/HSlider") \
		as HSlider).value


# helpers
func _is_root_scene() -> bool:
	return self == get_tree().root.get_child(0)

func _play_demo():
	start()

func _emit_event(event: PreGameEvent) -> void:
	if _is_root_scene():
		_handle_event_internally(event)
	else:
		event_bus.emit(event)

func _handle_event_internally(event: PreGameEvent) -> void:
	print_debug(event.to_dictionary())
	if event['type'] == PreGameEvent.QUIT_GAME:
		get_tree().quit()
