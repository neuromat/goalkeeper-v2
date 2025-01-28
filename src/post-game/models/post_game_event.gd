class_name PostGameEvent

# types
const GO_TO_PRE_GAME: String = 'GO_TO_PRE_GAME'
const QUIT_GAME: String = 'QUIT'

var type: String

func _init(type_: String) -> void:
	self.type = type_
