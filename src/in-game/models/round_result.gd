class_name RoundResult

var player_action: PlayerAction
var ai_action: AiAction
var winner: String

func _init(player_action_: PlayerAction, ai_action_: AiAction) -> void:
	self.player_action = player_action_
	self.ai_action = ai_action_
	self.winner = 'PLAYER' if player_action.choice == ai_action.choice else 'AI'


func to_dictionary() -> Dictionary:
	return {
		"player_action": self.player_action.to_dictionary(),
		"ai_action": self.ai_action.to_dictionary(),
		"winner": self.winner
	}

static func from_dictionary(dictionary: Dictionary) -> RoundResult:
	return RoundResult.new(
		PlayerAction.from_dictionary(dictionary["player_action"]),
		AiAction.from_dictionary(dictionary["ai_action"])
	)
