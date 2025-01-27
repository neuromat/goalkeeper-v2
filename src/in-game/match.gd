class_name Match
extends Node

var match_options: MatchOptions

var round_: int = 1
var player_actions: Array = []
var ai_actions: Array = []

func _is_root_scene() -> bool:
	return self == get_tree().root.get_child(0)

func _ready() -> void:
	# Running this scene isolated (F6) 
	# 	plays a match with `n_rounds`
	if _is_root_scene():
		_play_demo()

func _process(_delta: float) -> void:
	$MatchTransparentUi.update_realtime_timers(
		$ReadinessCountdown.time_left,
		$Player/Stopwatch.elapsed_time_in_us(),
		$FeedbackCountdown.time_left
	)

func _play_demo():
	initialize(_get_demo_data())
	await play()
	get_tree().quit()

func initialize(
	match_options_: MatchOptions):
	self.match_options = match_options_
	self.round_ = 1
	self.player_actions.clear()
	self.ai_actions.clear()
	
	var context_tree_file_path = match_options.context_tree_file_path
	$Player.pause()
	$ReadinessCountdown.one_shot = true
	$FeedbackCountdown.one_shot = true
	$MatchTransparentUi.initialize(context_tree_file_path)
	$AI.initialize(context_tree_file_path)

func play():
	for i in range(match_options.n_rounds):
		await play_round()
		var player_action = player_actions[i]
		var ai_action = ai_actions[i]
		$MatchTransparentUi.update(
			player_action, ai_action)
		await play_animations(player_action[0], ai_action[0])

func play_round() -> void:
	$ReadinessCountdown.start(match_options.readiness_time_in_s)
	await $ReadinessCountdown.timeout
	
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
	$FeedbackCountdown.start(match_options.feedback_time_in_s)
	$Player.play_animation(player_choice)
	$AI.play_animation(ai_choice)
	await $FeedbackCountdown.timeout

static func _get_demo_data():
	const context_tree_file_path = \
		'res://data/02_valid_context_tree_with_initial_context.csv'
	const n_rounds = 3
	const readiness_time = 1.25
	const feedback_time = 1.75
	return MatchOptions.new(
		context_tree_file_path, n_rounds,
		readiness_time, feedback_time)
