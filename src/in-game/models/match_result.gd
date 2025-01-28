class_name MatchResult

var round_results: Array = [] # Array<RoundResult>
var _statistics #: MatchStatistics # hit percentage, winner, etc...

func _init(round_results_: Array) -> void:
	self.round_results = round_results_
	# self.statistics = MatchStatistics.new(round_results_)

func to_dictionary() -> Dictionary:
	var round_results_as_dictionaries = []
	for r in self.round_results:
		round_results_as_dictionaries.append(
			(r as RoundResult).to_dictionary())
	return {
		"round_results": round_results_as_dictionaries
	}

static func from_dictionary(dictionary: Dictionary) -> MatchResult:
	var round_results_ = []
	var round_results_as_array_of_dicts: Array = dictionary['round_results']
	for r in round_results_as_array_of_dicts:
		round_results_.append(RoundResult.from_dictionary(r as Dictionary))
	return MatchResult.new(round_results_)
