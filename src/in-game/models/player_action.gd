class_name PlayerAction

var choice: String
var response_time_in_us: int

func _init(choice_: String, response_time_in_s_: int) -> void:
	self.choice = choice_
	self.response_time_in_us = response_time_in_s_
