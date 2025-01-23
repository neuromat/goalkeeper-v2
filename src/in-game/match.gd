class_name Match
extends Node

@export var round_countdown_in_s: float = 4.5
@export var feedback_countdown_in_s: float = 3.0
@export var transparent_ui_enabled = true

var round_: int = 1
var player_actions: Array = []
var ai_actions: Array = []

var context_tree_file_path: String
var n_rounds: int

func _is_root_scene() -> bool:
	return self == get_tree().root.get_child(0)

func _ready() -> void:
	# Running this scene isolated (F6) 
	# 	plays a match with `n_rounds`
	if _is_root_scene():
		_play_demo()

func _process(_delta: float) -> void:
	if transparent_ui_enabled: # TODO use show()/hide() instead
		$MatchTransparentUi.update_realtime_timers(
			$RoundCountdown.time_left,
			$Player/Stopwatch.elapsed_time_in_us(),
			$FeedbackCountdown.time_left
		)

func _play_demo():
	context_tree_file_path = \
		'res://data/02_valid_context_tree_with_initial_context.csv'
	n_rounds = 3
	# {
	#	"action": "PLAY", 
	#	"selected_context_tree_file_path": "...", 
	#	"match_options": {
	#		"n_rounds": 3, "setup_time": 1, "feedback_time": 1
	#	}
	# }
	const demo_match_options = {
		"n_rounds": 3,
		"setup_time": 1,
		"feedback_time": 1.25 
	}
	initialize(context_tree_file_path, demo_match_options)
	await play()
	get_tree().quit()

func initialize(
	context_tree_file_path_: String,
	match_options: Dictionary):
	$Player.pause()
	$RoundCountdown.one_shot = true
	$FeedbackCountdown.one_shot = true
	
	round_ = 1
	player_actions.clear()
	ai_actions.clear()
	
	$MatchTransparentUi.initialize(context_tree_file_path_)
	
	n_rounds = match_options['n_rounds']
	round_countdown_in_s = match_options['setup_time']
	feedback_countdown_in_s = match_options['feedback_time']
	context_tree_file_path = context_tree_file_path_
	$AI.initialize(context_tree_file_path_)

func play():
	for i in range(n_rounds):
		await play_round()
		var player_action = player_actions[i]
		var ai_action = ai_actions[i]
		$MatchTransparentUi.update(
			player_action, ai_action)
		await play_animations(player_action[0], ai_action[0])

func play_round() -> void:
	$RoundCountdown.start(round_countdown_in_s)
	await $RoundCountdown.timeout
	
	var player_action = await get_player_action() # [choice, response_time_in_us];
	var player_choice = player_action[0]
	
	if player_choice:
		player_actions.append(player_action)
		var ai_action = get_ai_action()
		ai_actions.append(ai_action)
		round_ += 1

func get_player_action(): # [choice, response_time_in_us]
	$Player.unpause()
	var action = await $Player.play_turn()
	$Player.pause()
	return action

func get_ai_action() -> Array:
	var action = $AI.play_turn()
	return action

func play_animations(
	player_choice: String, ai_choice: String) -> void:
	# it will only wait for the FeedbackCountdown to finish,
	# 	and ignore the animation time
	$FeedbackCountdown.start(feedback_countdown_in_s)
	$Player.play_animation(player_choice)
	$AI.play_animation(ai_choice)
	await $FeedbackCountdown.timeout
