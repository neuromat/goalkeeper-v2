class_name Stopwatch
extends Node

var start_in_us: int
var elapsed_in_us: int
var is_running: bool

func _ready() -> void:
	is_running = false
	elapsed_in_us = 0

func start() -> void:
	is_running = true
	start_in_us = Time.get_ticks_usec()

func stop() -> void:
	is_running = false
	var current_in_us = Time.get_ticks_usec()
	elapsed_in_us += (current_in_us - start_in_us)

func elapsed_time_in_us() -> int:
	if is_running:
		var time_since_last_start_in_us = Time.get_ticks_usec() - start_in_us
		return elapsed_in_us + time_since_last_start_in_us
	else:
		return elapsed_in_us

func reset() -> void:
	is_running = false
	elapsed_in_us = 0
