class_name AiAction

var choice: String
var context: String
var probability: float

func _init(choice_: String, context_: String, probability_: float) -> void:
	self.choice = choice_
	self.context = context_
	self.probability = probability_
