class_name PlayerAction

var choice: String
var response_time_in_us: int

func _init(choice_: String, response_time_in_s_: int) -> void:
	self.choice = choice_
	self.response_time_in_us = response_time_in_s_


func to_dictionary() -> Dictionary:
	return { "choice": self.choice,
		"response_time_in_us": self.response_time_in_us }

static func from_dictionary(dictionary: Dictionary) -> PlayerAction:
	return PlayerAction.new(dictionary["choice"], dictionary["response_time_in_us"])
