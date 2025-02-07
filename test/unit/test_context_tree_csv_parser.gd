class_name TestContextTreeCsvParser
extends GutTest

# --- Testing scope ---
# 1. the parser should handle valid and invalid Context Tree
# 	CSV descriptions as sparse probability table
# 2. tests are more extensive in the core validation methods
# 	and less in the higher level API
# 3. the parser acts on syntax and semantics validation

var test_parameters_probabilities = [
	# probabilities_line, is_valid, expected_probability, expected_errors_size
	# valid
	[['0.3', '0.7'], [.3, .7], 0],
	[['0.2', '0.6'], [.2, .6], 0],
	[['1.0', '0.0'], [1.0, .0], 0],
	[['0.0', '1.0'], [.0, 1.0], 0],
	[['0.0', '0.0'], [.0, .0], 0],
	[['0.314159265', '0.0'], [.3141593, .0], 0],
	[['0.314159265', '0.685840735'], [.3141593, .685841], 0],
	[[' 0.22', '0.7  '], [.22, .7], 0],
	# invalid
	[['0.3', '.2'], [], 1], # `.2` does not convert to `0.2`
	[['-0.3', '0.7'], [], 1],
	[['0.45', '0.7'], [], 1],
	[['two', '0.9'], [], 1],
	[['0.3', '0.4', '0.3'], [], 1],
	[['0.3'], [], 1],
	[['1.3', 'two'], [], 2]
]
func test_should_validate_probability_values(
	params=use_parameters(test_parameters_probabilities)):
	# given
	var probabilities_line = params[0]
	
	# when
	var result: Dictionary = ContextTreeCsvParser._parse_probabilities(probabilities_line)

	# then
	var expected_errors_size = params[2]
	assert_eq((result['errors'] as Array).size(), expected_errors_size)

	# and
	if expected_errors_size > 0:
		var expected_probabilities = params[1]
		for i in expected_probabilities.size():
			assert_almost_eq(result['probabilities'][i], expected_probabilities[i], .000_001)

var test_parameters_contexts = [
	# context, expected_context, expected_is_initial_context, expected_errors_size
	# valid
	['LEFT', 'LEFT', false, 0],
	['LEFT>RIGHT', 'LEFT>RIGHT', false, 0],
	['  CENTER >    LEFT ', 'CENTER>LEFT', false, 0],
	['right >LefT  >  CENTER', 'RIGHT>LEFT>CENTER', false, 0],
	['*LEFT', 'LEFT', true, 0],
	['*LEFT>RIGHT', 'LEFT>RIGHT', true, 0],
	[' * CENTER >    LEFT ', 'CENTER>LEFT', true, 0],
	['*right >LefT  >  CENTER', 'RIGHT>LEFT>CENTER', true, 0],
	# invalid context
	['', null, false, 1],
	['FOO', null, false, 1],
	['RIGHT>FOO', null, false, 1],
	['>RIGHT', null, false, 1],
	['RIGHT>LEFT>', null, false, 1],
	['RIGHT LEFT', null, false, 1],
	['RIGHT>>LEFT', null, false, 1],
	# invalid '*' placement
	['LEFT*', null, false, 1],
	['LEFT>*RIGHT', null, false, 1],
	['*FOO>RIGHT', null, false, 1],
	['**LEFT>CENTER>RIGHT', null, false, 1]
]
func test_should_parse_context_column(
	params=use_parameters(test_parameters_contexts)):
	# given
	var context = params[0]
	
	# when
	var result: Dictionary = ContextTreeCsvParser._parse_context(context)
	
	# then
	var expected_context = params[1]
	assert_eq(result['context'], expected_context)
	var expected_is_initial_context = params[2]
	assert_eq(result['is_initial_context'], expected_is_initial_context)
	var expected_errors_size = params[3]
	assert_eq((result['errors'] as Array).size(), expected_errors_size)

var test_parameters_csv_lines = [
	# csv_line, expected_context, expected_probabilities, expected_errors_size
	# valid
	['LEFT,0.5,0.4', 'LEFT', [.5, .4], 0],
	['right > center,0.3,0.7', 'RIGHT>CENTER', [.3, .7], 0],
	# invalid
	['', null, [], 3], # values size; not a context; probabilities size
	['foo,-0.3,10.4', null, [], 3], # not a context; prob < 0.0; prob > 1.0
	['Center>Left,0.6,0.55', null, [], 1], # sum prob > 1.0
	['LEFT>bar>LEFT,,0.3,0.6', null, [], 3] # values size > 3; not a context; prob size > 2
]
func test_should_parse_csv_lines(
	params=use_parameters(test_parameters_csv_lines)):
	# given
	var csv_line = params[0]
	var line_number = 3 # any line number
	
	# when
	var result = ContextTreeCsvParser._parse_line(line_number, csv_line)
	
	# and
	var context = result['context']
	var probabilities: Array = result['probabilities']
	var errors: Array = result['errors']

	# then
	var expected_context = params[1]
	assert_eq(context, expected_context)
	
	# and
	var expected_errors_size = params[3]
	assert_eq(errors.size(), expected_errors_size)
	if expected_errors_size == 0:
		var expected_probabilities = params[2]
		for i in expected_probabilities.size():
			assert_almost_eq(probabilities[i], expected_probabilities[i], .000_001)

var test_parameters_csv_files_paths = [
	'res://data/test/tabs_instead_of_spaeces.csv',
	'res://data/test/01_valid_context_tree.csv',
	'res://data/test/unreachable.csv'
]
func test_should_parse_syntatically_valid_csv_files(
	params=use_parameters(test_parameters_csv_files_paths)):
	# given
	var file_path = params
	
	# when
	var result = ContextTreeCsvParser.parse(file_path)
	print_debug(result)
	
	# then
	var errors = result['errors'] as Array
	var contexts_and_probabilities = result['contexts_and_probabilities'] as Array
	assert_eq(errors.size(), 0)
	assert_ne(contexts_and_probabilities.size(), 0)
