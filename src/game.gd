class_name Game
extends Node

@onready var pre_game_scene: PackedScene = preload("res://src/pre-game/pre_game.tscn")
@onready var in_game_scene: PackedScene = preload("res://src/in-game/in_game.tscn")
@onready var post_game_scene: PackedScene = preload("res://src/post-game/post_game.tscn")

var pre_game_node: PreGame
var in_game_node: InGame
var post_game_node: PostGame

var context_tree_file_path: String
var n_rounds: int = 3
var node_loaded: String

func _ready() -> void:
	_setup()
	pre_game_node = pre_game_scene.instantiate()
	# Running this scene isolated (F6)
	if _is_root_scene():
		_play_demo()

func _setup() -> void:
	DefaultFilesLoader.load()

func _is_root_scene() -> bool:
	return self == get_tree().root.get_child(0)

func _play_demo():
	_load_pre_game()


func _unload_current() -> void:
	if not node_loaded:
		return
	if node_loaded == 'PRE_GAME':
		pre_game_node.event_bus.disconnect(_on_pre_game_event)
		remove_child(pre_game_node)
	elif node_loaded == 'IN_GAME':
		in_game_node.event_bus.disconnect(_on_in_game_event)
		remove_child(in_game_node)
	elif node_loaded == 'POST_GAME':
		post_game_node.event_bus.disconnect(_on_post_game_event)
		remove_child(post_game_node)

func _load_pre_game() -> void:
	_unload_current()
	pre_game_node = pre_game_scene.instantiate()
	add_child(pre_game_node)
	pre_game_node.event_bus.connect(_on_pre_game_event)
	node_loaded = 'PRE_GAME'
	pre_game_node.start()

func _load_in_game(options: InGameOptions) -> void:
	_unload_current()
	in_game_node = in_game_scene.instantiate()
	add_child(in_game_node)
	in_game_node.event_bus.connect(_on_in_game_event)
	node_loaded = 'IN_GAME'
	in_game_node.start(options)

func _load_post_game() -> void:
	_unload_current()
	post_game_node = post_game_scene.instantiate()
	add_child(post_game_node)
	post_game_node.event_bus.connect(_on_post_game_event)
	node_loaded = 'POST_GAME'

func _on_pre_game_event(event: PreGameEvent) -> void:
	if event.type == PreGameEvent.QUIT_GAME:
		quit()
	elif event.type == PreGameEvent.START_MATCH:
		_load_in_game(InGameOptions.new(event.match_options))

func _on_in_game_event(event: InGameEvent) -> void:
	print_debug(event.to_dictionary())
	_load_post_game()
	pass

func _on_post_game_event(event: PostGameEvent) -> void:
	var type = event.type
	if type == PostGameEvent.GO_TO_PRE_GAME:
		_load_pre_game()
	elif type == PostGameEvent.QUIT_GAME:
		quit()


func quit() -> void:
	get_tree().quit()
