class_name TestLegacyContextTreeFileParser
extends GutTest

# --- Testing scope ---
# 1. the parser should handle valid and invalid Legacy Context Tree
# 	Files (Custom Trees)
# 2. tests are more extensive in the core validation methods
# 	and less in the higher level API
# 3. the parser acts on syntax and semantics validation

var test_parameters_files_paths = [
	# [ target file, length of "contexts_and_probabilities" ]
	['res://data/test/legacy/diamante_tree_1.txt', 3],
	['res://data/test/legacy/diamante_tree_2.txt', 4],
	['res://data/test/legacy/diamante_tree_4.txt', 7]
]
func test_should_validate_probability_values(
	params=use_parameters(test_parameters_files_paths)):
	# given
	var file_path = params[0]
	
	# when
	var result: Dictionary = LegacyContextTreeFileParser.parse(file_path)
	print(result)

	# then
	var errors = result['errors'] as Array
	assert_eq(errors.size(), 0)
	
	# and
	var contexts_and_probabilities = result['contexts_and_probabilities'] as Array
	var expected_context_and_probabilities_size = params[1]
	assert_eq(contexts_and_probabilities.size(), expected_context_and_probabilities_size)

func test_should_validate_probability_values_2():
	# given
	var file_path = 'res://data/test/legacy/diamante_tree_3.txt'
	
	# when
	var result: Dictionary = LegacyContextTreeFileParser.parse(file_path)
	print(result)

	# then
	var errors = result['errors'] as Array
	assert_eq(errors.size(), 0)
	
	# and
	var contexts_and_probabilities = result['contexts_and_probabilities'] as Array
	var expected_contexts_and_probabilities = [
		{"context": "RIGHT", "probabilities": [.25, .75]},
		{"context": "RIGHT>CENTER", "probabilities": [1.0, 0.0]},
		{"context": "RIGHT>LEFT", "probabilities": [1.0, 0.0]},
		{"context": "CENTER>LEFT", "probabilities": [.25, .75]},
		{"context": "LEFT>CENTER", "probabilities": [0.0, 0.0]},
		{"context": "RIGHT>LEFT>LEFT", "probabilities": [.25, .75]},
		{"context": "CENTER>LEFT>LEFT", "probabilities": [0.0, 0.0]},
		{"context": "LEFT>LEFT>LEFT", "probabilities": [0.0, 0.0]}
	]
	assert_eq(contexts_and_probabilities, expected_contexts_and_probabilities)
