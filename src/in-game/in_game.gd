class_name InGame
extends Node

signal event_bus(event: Dictionary)

func _ready() -> void:
	if _is_root_scene():
		_play_demo()

func _is_root_scene() -> bool:
	return self == get_tree().root.get_child(0)

func _play_demo():
	var match_options = MatchOptions.new(
			"res://data/01_valid_context_tree.csv", 3, .75, 1.25)
	var demo_options = InGameOptions.new(match_options)
	await start(demo_options)

# public
func start(in_game_options: InGameOptions) -> void:
	var match_result = await _play_match(
		in_game_options.match_options)
	var in_game_event = InGameEvent.new(match_result)
	if _is_root_scene():
		print_debug(in_game_event.to_dictionary())
		get_tree().quit()
	else:
		event_bus.emit(in_game_event)


# private
func _play_match(match_options: MatchOptions) -> MatchResult:
	$Match.initialize(match_options)
	var result: MatchResult = await $Match.play()
	return result
