class_name TestMatchOptions
extends GutTest

const test_validation_params =[
	# n_rounds, readiness, feedback, errors
	[5, 0.9, 1.25, 0],
	#	n_rounds
	[1, 0.9, 1.25, 0],
	[0, 0.9, 1.25, 1],
	[-1, 0.9, 1.25, 1],
	[-5, 0.9, 1.25, 1],
	#	readness and feedback
	[5, 0, 1.25, 0], # no readiness time
	[5, -0.1, 1.25, 1],
	[5, -.0000001, 0, 2],
	[5, 1.25, -.00000001, 1]
]
func test_should_push_errors_(
	params=use_parameters(test_validation_params)):
	# given
	var n_rounds = params[0]
	var readiness_time_in_s = params[1]
	var feedback_time_in_s = params[2]
	
	# when
	var errors = MatchOptions._validate(n_rounds,
		readiness_time_in_s, feedback_time_in_s)
	
	# then
	var expected_errors_size = params[3]
	assert_eq(errors.size(), expected_errors_size)
