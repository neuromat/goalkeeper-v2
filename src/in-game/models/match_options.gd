class_name MatchOptions

var n_rounds: int
var readiness_time_in_s: float
var feedback_time_in_s: float
var context_tree_file_path: String

func _init(
	context_tree_file_path_: String,
	n_rounds_: int,
	readiness_time_in_s_: float,
	feedback_time_in_s_: float):
	var errors = _validate(n_rounds_,
		readiness_time_in_s_, feedback_time_in_s_)
	assert(errors.size() == 0, 'invalid MatchOptions initialization')
	self.context_tree_file_path = context_tree_file_path_ # TODO validate
	self.n_rounds = n_rounds_
	self.readiness_time_in_s = readiness_time_in_s_
	self.feedback_time_in_s = feedback_time_in_s_

static func _validate(n_rounds_: int,
	readiness_time_in_s_: float,
	feedback_time_in_s_: float,
	testing: bool = false) -> Array:
	var errors: Array = []
	if n_rounds_ <= 0:
		errors.append("\n\t'n_rounds' must be > 0")
	if readiness_time_in_s_ < 0.0:
		errors.append("\n\t'readiness_time_in_s' must be >= 0")
	if feedback_time_in_s_ <= 0.0:
		errors.append("\n\t'feedback_time_in_s' must be > 0")
	return errors
