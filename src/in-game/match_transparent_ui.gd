extends Control

class_name MatchTransparentUi

@onready var context_tree_file_path_label: Label = $TopContainer/VBoxContainer/ContextTreeFilePath
@onready var player_history: VBoxContainer = $TopContainer/VBoxContainer/HBoxContainer/PlayerHistory
@onready var ai_history: VBoxContainer = $TopContainer/VBoxContainer/HBoxContainer/AiHistory

# realtime labels
@onready var readiness_label: Label = $MarginContainer2/HBoxContainer2/Readiness
@onready var response_label: Label = $MarginContainer2/HBoxContainer2/Response
@onready var feedback_label: Label = $MarginContainer2/HBoxContainer2/Feedback

func _add_to_player_history(player_action: PlayerAction):
	var label = Label.new()
	label.text = "%s: %s (us)" % [ player_action.choice, player_action.response_time_in_us ]
	player_history.add_child(label)
	
func _add_to_ai_history(ai_action: AiAction):
	# ai_action: [choice, context, probability]
	var label = Label.new()
	label.text = "%s: %s | %0.3f" % [ ai_action.context, \
		ai_action.choice, ai_action.probability]
	ai_history.add_child(label)

func _update_context_tree_file_path(context_tree_file_path: String):
	context_tree_file_path_label.text = "Context Tree: %s" \
		% context_tree_file_path

func update_realtime_timers(
	readiness_in_s: float, response_in_us: float, feedback_in_s: float) -> void:
	var response_in_s: float = response_in_us / pow(10, 6)
	readiness_label.text = "Readiness (s): %0.2f" % readiness_in_s
	response_label.text = "Response (s): %0.6f" % response_in_s
	feedback_label.text = "Feedback (s): %0.2f" % feedback_in_s

func update(round_result: RoundResult):
	_add_to_player_history(round_result.player_action)
	_add_to_ai_history(round_result.ai_action)

func initialize(
	context_tree_file_path: String) -> void:
	update_realtime_timers(0, 0, 0)
	_update_context_tree_file_path(context_tree_file_path)
	#_clear_player_history()
	#_clear_ai_history()

func _clear_player_history() -> void:
	var n_children = player_history.get_child_count()
	for i in range(1, n_children): # skip title
		player_history.remove_child(
			player_history.get_child(i))

func _clear_ai_history() -> void:
	var n_children = ai_history.get_child_count()
	for i in range(1, n_children): # skip title
		ai_history.remove_child(
			ai_history.get_child(i))
