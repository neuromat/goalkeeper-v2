class_name TestLegacyContextTreeFileParser
extends GutTest

# --- Testing scope ---
# 1. the parser should handle valid and invalid Legacy Context Tree
# 	Files (Custom Trees)
# 2. tests are more extensive in the core validation methods
# 	and less in the higher level API
# 3. the parser acts on syntax and semantics validation

var test_parameters_files_paths = [
	'res://data/test/legacy/diamante_tree_4.txt',
]
func test_should_validate_probability_values(
	params=use_parameters(test_parameters_files_paths)):
	# given
	var file_path = params
	
	# when
	var result: Dictionary = LegacyContextTreeFileParser.parse(file_path)
	print(result)

	# then
	var errors = result['errors'] as Array
	assert_eq(errors.size(), 0)
	
	# and
	var contexts_and_probabilities = result['contexts_and_probabilities'] as Array
	assert_eq(contexts_and_probabilities.size(), 7)
