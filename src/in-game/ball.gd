class_name Ball
extends Node

signal done

const ANIMATION_DURATION_IN_S = .6
var should_move: bool = false
var path_progress = 0.0
var current_follow_path: PathFollow2D

func _ready() -> void:
	# Running this scene isolated (F6) 
	# 	plays 5 consecutive turns
	if _is_root_scene():
		_play_demo()
		
func _process(delta: float) -> void:
	if should_move:
		_move(delta)

func _is_root_scene() -> bool:
	return self == get_tree().root.get_child(0)

func _move(delta: float) -> void:
	var incremental_progress = clampf(delta / ANIMATION_DURATION_IN_S, .0, 1.0)
	path_progress = clampf(path_progress + incremental_progress, .0, 1.0)
	current_follow_path.progress_ratio = path_progress
	if path_progress >= 1.0:
		should_move = false
		done.emit()

func play_animation(choice: String):
	should_move = true
	match choice:
		'LEFT':
			current_follow_path = $LeftPath/LeftFollowPath
		'RIGHT':
			current_follow_path = $RightPath/RightFollowPath
		_:
			current_follow_path = $CenterPath/CenterFollowPath
	current_follow_path.get_node("AnimatedBall").play('in-air')
	await done

func reset_position():
	should_move = false
	path_progress = .0
	if current_follow_path:
		current_follow_path.progress_ratio = .0
		var animated_ball: AnimatedSprite2D = current_follow_path.get_node("AnimatedBall")
		animated_ball.play('idle')
		await animated_ball.animation_finished

func _play_demo():
	const choices = ['LEFT', 'CENTER', 'RIGHT']
	$DemoTimer.one_shot = true
	for i in range(0, 5):
		await reset_position()
		await play_animation(choices[i % 3])
		$DemoTimer.start(4.0)
		await $DemoTimer.timeout
	get_tree().quit()
