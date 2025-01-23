class_name InGame
extends Node

signal event_bus(event: Dictionary)

func _ready() -> void:
	if _is_root_scene():
		_play_demo()

func _is_root_scene() -> bool:
	return self == get_tree().root.get_child(0)

func _play_demo():
	const demo_options = {
		'match_options': {
			'context_tree_file_path': \
				'res://data/01_valid_context_tree.csv',
			'n_rounds': 4,
			'setup_time': 2.5,
			'feedback_time': 1.25
		}
	}
	await start(demo_options)

# public
func start(options: Dictionary) -> void:
	var event = await _play_match(options['match_options'])
	
	if _is_root_scene():
		get_tree().quit()
	else:
		event_bus.emit(event)


# private
func _play_match(options: Dictionary) -> Dictionary:
	var context_tree_file_path = options['context_tree_file_path']
	$Match.initialize(
		context_tree_file_path,
		options)
	# TODO: $Match.play() should return data from the match
	# 	including "MATCH_ABANDONED"
	await $Match.play()
	return {
		"type": "MATCH_ENDED",
		"data": {}
	}
