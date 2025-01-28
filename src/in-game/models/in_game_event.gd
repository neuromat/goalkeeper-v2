class_name InGameEvent

var match_result: MatchResult

func _init(match_result_: MatchResult):
	self.match_result = match_result_

func to_dictionary() -> Dictionary:
	return { "match_result": self.match_result.to_dictionary() }

static func from_dictionary(dictionary: Dictionary) -> InGameEvent:
	return InGameEvent.new(MatchResult.from_dictionary(dictionary))
