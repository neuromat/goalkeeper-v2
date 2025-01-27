class_name PreGameEvent

# types
const START_MATCH: String = 'START_MATCH'
const QUIT_GAME: String = 'QUIT'

var type: String
var match_options: MatchOptions

func _init(
	type_: String,
	match_options_: MatchOptions = null):
	self.type = type_
	if type == START_MATCH :
		if MatchOptions == null:
			assert(false, "START_MATCH type requires MatchOptions")
		else:
			self.match_options = match_options_

func to_dictionary() -> Dictionary:
	return {
		"type": self.type,
		"match_options": self.match_options.to_dictionary()
	}

static func from_dictionary(dictionary: Dictionary) -> PreGameEvent:
	return PreGameEvent.new(
		dictionary['type'],
		MatchOptions.from_dictionary(
			dictionary['match_options'] as Dictionary)
	)
