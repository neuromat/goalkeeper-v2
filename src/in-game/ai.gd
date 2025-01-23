class_name Ai
extends Node

@export var context_tree_file_path: String = 'res://data/01_valid_context_tree.csv'

var context_tree: ContextTree

func _ready() -> void:
	# Running this scene isolated (F6) 
	# 	plays 10 consecutive turns
	if _is_root_scene():
		_play_demo()

func _is_root_scene() -> bool:
	return self == get_tree().root.get_child(0)
	
func _play_demo():
	initialize(context_tree_file_path)
	for i in range(0, 10):
		var action = play_turn()
		await play_animation(action[0])
	get_tree().quit()

func initialize(context_tree_file_path_: String):
	context_tree = ContextTree.new()
	context_tree.initialize(context_tree_file_path_)

func play_turn() -> Array: # [choice, context, probability]
	return context_tree.get_action()

func play_animation(choice: String):
	await $Ball.play_animation(choice)
	await $Ball.reset_position()
