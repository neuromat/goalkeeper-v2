class_name TestContextTree
extends GutTest

# --- Testing scope ---
# 1. tests assume contexts_and_probabilities come from
# 	the parser, and are syntaticaly valid
# 2. tests should validate the whole Context Tree, identifying
# 	unreacheable contexts
# 3. `context_tree_graph` is considered valid in tests asserting
#	choices from the context tree
# 4. in `test_parameters`, `choices` match the `current_context`
#		i.e. only `choice`s with probability > 0 for the given
#		`current_context` are included

func test_should_build_a_valid_graph():
	# given
	var contexts_and_probabilities = [
		{ "context": "LEFT", "probabilities": [.0, .3] },
		{ "context": "LEFT>CENTER", "probabilities": [.0, 1.0] },
		{ "context": "CENTER>CENTER", "probabilities": [1.0, .0] },
		{ "context": "RIGHT>CENTER", "probabilities": [1.0, .0] },
		{ "context": "RIGHT", "probabilities": [.0, 1.0] }
	]
	
	# when
	var result = ContextTree._build_context_tree_graph(contexts_and_probabilities)
	
	# then
	var expected_graph = {
		"LEFT": { "LEFT": .0, "CENTER": .3 },
		"LEFT>CENTER": { "LEFT": .0, "CENTER": 1.0 },
		"CENTER>CENTER": { "LEFT": 1.0, "CENTER": .0 },
		"RIGHT>CENTER": { "LEFT": 1.0, "CENTER": .0 },
		"RIGHT": { "LEFT": .0, "CENTER": 1.0 }
	}
	assert_eq_deep(result['graph'], expected_graph)
	assert_eq_deep(result['errors'], [])

func test_should_build_an_empty_graph_when_there_are_errors():
	# given
	var contexts_and_probabilities = [
		{ "context": "LEFT", "probabilities": [.0, .3] },
		{ "context": "LEFT", "probabilities": [.0, 1.0] }, # previously defined
		{ "context": "CENTER>CENTER", "probabilities": [1.0, .0] },
		{ "context": "RIGHT>CENTER", "probabilities": [1.0, .0] },
		{ "context": "RIGHT", "probabilities": [.0, 1.0] },
		{ "context": "CENTER>CENTER", "probabilities": [.7, .3] }, # previously defined
	]
	
	# when
	var result = ContextTree._build_context_tree_graph(contexts_and_probabilities)
	
	# then
	assert_eq((result['errors'] as Array).size(), 2)
	assert_eq_deep(result['graph'], {})

const context_tree_max_size_1: Dictionary = {
	"LEFT": {"LEFT": .1, "CENTER": .0},
	"CENTER": {"LEFT": .5, "CENTER": .5},
	"RIGHT": {"LEFT": .0, "CENTER": .7}
}
var test_parameters_max_size_1 = [
	# current_context, choice, expected
	["LEFT", "LEFT", "LEFT"],
	["LEFT", "RIGHT", "RIGHT"],
	["CENTER", "LEFT", "LEFT"],
	["CENTER", "CENTER", "CENTER"],
	["RIGHT", "CENTER", "CENTER"],
	["RIGHT", "RIGHT", "RIGHT"]
]
func test_should_get_the_next_context_for_context_tree_max_size_1(
	params=use_parameters(test_parameters_max_size_1)):
	# given
	var current_context = params[0]
	var choice = params[1]
	
	# when
	var context = ContextTree._get_next_context(
		context_tree_max_size_1, current_context, choice)
		
	# then
	var expected = params[2]
	assert_eq(context, expected)

const context_tree_max_size_2: Dictionary = {
	"LEFT": {"LEFT": .0, "CENTER": .3},
	"LEFT>CENTER": {"LEFT": .0, "CENTER": 1.0},
	"CENTER>CENTER": {"LEFT": 1.0, "CENTER": .0},
	"RIGHT>CENTER": {"LEFT": 1.0, "CENTER": .0},
	"RIGHT": {"LEFT": .0, "CENTER": 1.0}
}
var test_parameters_max_size_2 = 	[
	# current_context, choice, expected
	["LEFT", "CENTER", "LEFT>CENTER"],
	["LEFT", "RIGHT", "RIGHT"],
	["LEFT>CENTER", "CENTER", "CENTER>CENTER"],
	["CENTER>CENTER", "LEFT", "LEFT"],
	["RIGHT>CENTER", "LEFT", "LEFT"],
	["RIGHT", "CENTER", "RIGHT>CENTER"]
]
func test_should_get_the_next_context_for_context_tree_max_size_2(
	params=use_parameters(test_parameters_max_size_2)):
	# given
	var current_context = params[0]
	var choice = params[1]
	
	# when
	var context = ContextTree._get_next_context(
		context_tree_max_size_2, current_context, choice)
	
	# then
	var expected = params[2]
	assert_eq(context, expected)

var test_parameters_initial_contexts = [
	null, 'LEFT', 'LEFT>CENTER', 'CENTER>CENTER', 'RIGHT>CENTER', 'RIGHT'
]
func test_should_validate_a_context_tree_given_an_initial_context(
	params=use_parameters(test_parameters_initial_contexts)):
	# given
	var context_tree = {
		"LEFT": { "LEFT": .0, "CENTER": .3 },
		"LEFT>CENTER": { "LEFT": .0, "CENTER": 1.0 },
		"CENTER>CENTER": { "LEFT": 1.0, "CENTER": .0 },
		"RIGHT>CENTER": { "LEFT": 1.0, "CENTER": .0 },
		"RIGHT": { "LEFT": .0, "CENTER": 1.0 }
	}
	var initial_context = params
	
	# when
	var result = ContextTree._validate_graph(initial_context, context_tree)
	
	# then
	assert_eq_deep(result['graph'], context_tree)
	assert_eq(result['errors'].size(), 0)

var test_parameters_non_center_initial_contexts = [
	'LEFT', 'LEFT>RIGHT', 'RIGHT>RIGHT'
]
func test_should_validate_a_context_tree_without_center_context(
	params=use_parameters(test_parameters_non_center_initial_contexts)):
	# given
	var context_tree = {
		"LEFT": { "LEFT": .0, "CENTER": .0 },
		"LEFT>RIGHT": { "LEFT": .35, "CENTER": .0 },
		"RIGHT>RIGHT": { "LEFT": .8, "CENTER": .0 }
	}
	var initial_context = params
	
	# when
	var result = ContextTree._validate_graph(initial_context, context_tree)
	
	# then
	assert_eq_deep(result['graph'], context_tree)
	assert_eq(result['errors'].size(), 0)

var test_parameters_invalid_initial_contexts = [
	'CENTER', 'LEFT>LEFT', 'LEFT>RIGHT', 'CENTER>LEFT', 'CENTER>RIGHT', 'RIGHT>LEFT', 'RIGHT>RIGHT'
]
func test_should_validate_a_context_tree_given_an_invalid_initial_context(
	params=use_parameters(test_parameters_invalid_initial_contexts)):
	# given
	var context_tree = {
		"LEFT": { "LEFT": .0, "CENTER": .3 },
		"LEFT>CENTER": { "LEFT": .0, "CENTER": 1.0 },
		"CENTER>CENTER": { "LEFT": 1.0, "CENTER": .0 },
		"RIGHT>CENTER": { "LEFT": 1.0, "CENTER": .0 },
		"RIGHT": { "LEFT": .0, "CENTER": 1.0 }
	}
	var initial_context = params
	
	# when
	var result = ContextTree._validate_graph(initial_context, context_tree)
	
	# then
	assert_eq_deep(result['graph'], {})
	assert_eq(result['errors'].size(), 1)

var test_parameters_invalid_context_trees_with_initial_context = [
	# initial_context, context_tree
	['LEFT', {
		"LEFT": { "LEFT": .0, "CENTER": .3 },
		"LEFT>CENTER": { "LEFT": .0, "CENTER": 1.0 },
		"CENTER>CENTER": { "LEFT": 1.0, "CENTER": .0 },
		"RIGHT>CENTER": { "LEFT": 1.0, "CENTER": .0 },
		"RIGHT": { "LEFT": .5, "CENTER": .0 } # RIGHT>CENTER unreacheable
	}],
]
func test_should_give_an_error_for_a_context_tree_with_unreacheable_contexts(
	params=use_parameters(test_parameters_invalid_context_trees_with_initial_context)):
	# given
	var initial_context = params[0]
	var context_tree = params[1]
	
	# when
	var result = ContextTree._validate_graph(initial_context, context_tree)
	
	# then
	assert_eq_deep(result['graph'], {})
	assert_eq((result['errors'] as Array).size(), 1)

#var test_parameters_valid_context_trees = [
	## file_path, expected_initial_context
	#['res://test/unit/resources/01_valid_context_tree.csv', null],
	#['res://test/unit/resources/02_valid_context_tree_with_initial_context.csv', 'CENTER>CENTER']
#]
#func test_should_create_a_valid_context_tree_from_csv_file(
	#params=use_parameters(test_parameters_valid_context_trees)):
	## given
	#var file_path = params[0]
	#var context_tree = autofree(ContextTree.new())
	#
	## when
	#var result = context_tree.initialize(file_path)
	#
	## then
	#var expected_initial_context = params[1]
	#var expected_graph = {
		#"LEFT": { "LEFT": .0, "CENTER": .3 },
		#"LEFT>CENTER": { "LEFT": .0, "CENTER": 1.0 },
		#"CENTER>CENTER": { "LEFT": 1.0, "CENTER": .0 },
		#"RIGHT>CENTER": { "LEFT": 1.0, "CENTER": .0 },
		#"RIGHT": { "LEFT": .0, "CENTER": 1.0 }
	#}
	#var errors = result['errors'] as Array
	#assert_eq(context_tree.initial_context, expected_initial_context)
	#assert_eq_deep(context_tree.graph, expected_graph)
	#assert_eq(errors.size(), 0)

var test_parameters_random_variable = [
	# current_context, random_variable, expected_choice, expected_probability
	# LEFT | LEFT=.0 | CENTER=.3
	["LEFT", .000_1, "CENTER", .3],
	["LEFT", .3, "CENTER", .3],
	["LEFT", .300_1, "RIGHT", .7],
	["LEFT", 1.0, "RIGHT", .7],
	# LEFT>CENTER | LEFT=.0 | CENTER=1.0
	["LEFT>CENTER", .000_1, "CENTER", 1.0],
	["LEFT>CENTER", 1.0, "CENTER", 1.0],
	# CENTER>CENTER | LEFT=1.0 | CENTER=.0
	["CENTER>CENTER", .000_1, "LEFT", 1.0],
	["CENTER>CENTER", 1.0, "LEFT", 1.0],
	# RIGHT>CENTER | LEFT=1.0 | CENTER=.0
	["RIGHT>CENTER", .000_1, "LEFT", 1.0],
	["RIGHT>CENTER", 1.0, "LEFT", 1.0],
	# RIGHT | LEFT=.0 | CENTER=1.0
	["RIGHT", .000_1, "CENTER", 1.0],
	["RIGHT", 1.0, "CENTER", 1.0],
]
func test_should_get_action_given_context_tree_and_random_variable(
	params=use_parameters(test_parameters_random_variable)
	):
	# given
	var current_context = params[0]
	var random_variable = params[1]
	
	# and
	var float_error = .05
	
	# when
	var action = ContextTree._get_action_from_random_variable(
		random_variable, context_tree_max_size_2, current_context)
	
	# then
	var choice = action[0]
	var context = action[1]
	var probability = action[2]
	assert_eq(choice, params[2])
	assert_eq(context, current_context)
	assert_almost_eq(probability, params[3], float_error)
