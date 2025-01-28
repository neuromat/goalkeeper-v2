class_name PostGame
extends Node

signal event_bus(event: PostGameEvent)

func _on_next_pressed() -> void:
	var event = PostGameEvent.new(PostGameEvent.GO_TO_PRE_GAME)
	event_bus.emit(event)

func _on_quit_pressed() -> void:
	var event = PostGameEvent.new(PostGameEvent.QUIT_GAME)
	event_bus.emit(event)
