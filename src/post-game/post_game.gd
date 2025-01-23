class_name PostGame
extends Node

signal event_bus(event: Dictionary)

func _on_next_pressed() -> void:
	var event = { 'action': 'NEXT' }
	event_bus.emit(event)

func _on_quit_pressed() -> void:
	var event = { 'action': 'QUIT' }
	event_bus.emit(event)
