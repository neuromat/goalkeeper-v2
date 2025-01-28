class_name AiAction

var choice: String
var context: String
var probability: float

func _init(choice_: String, context_: String, probability_: float) -> void:
	self.choice = choice_
	self.context = context_
	self.probability = probability_

func to_dictionary() -> Dictionary:
	return {
		"choice": self.choice,
		"context": self.context,
		"probability": self.probability
	}

static func from_dictionary(dictionary: Dictionary) -> AiAction:
	return AiAction.new(dictionary["choice"], dictionary["context"], dictionary["probability"])
