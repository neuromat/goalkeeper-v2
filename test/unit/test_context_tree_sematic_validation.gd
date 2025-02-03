class_name TestContextTreeSemanticValidation
extends GutTest

var test_parameters_invalid_context_tree = [
	# context_tree
	{
		"RIGHT": { "LEFT": .25, "CENTER": .75 },
		"RIGHT>CENTER": { "LEFT": 1, "CENTER": 0 },
		"RIGHT>LEFT": { "LEFT": 1, "CENTER": 0 },
		"CENTER>LEFT": { "LEFT": .25, "CENTER": .75 },
		"LEFT>CENTER": { "LEFT": 0, "CENTER": 0 },
		"RIGHT>LEFT>CENTER": { "LEFT": .25, "CENTER": .75 },
		"LEFT>LEFT>LEFT": { "LEFT": 0, "CENTER": 0 }
	}]
	# *RIGHT --(C)--> RIGHT>CENTER --(L)--> CENTER>LEFT --(L)--> ?
	# *RIGHT>CENTER --(L)--> CENTER>LEFT --(L)--> ?
	# *CENTER>LEFT --(L)--> ?
	# (*) initial_context 
func test_should_return_empty_for_incomplete_context_tree(
	params=use_parameters(test_parameters_invalid_context_tree)):
	# given
	var context_tree = params
	
	# when
	var result = ContextTree._validate_graph(null, context_tree)
	
	# then
	assert_eq_deep(result['graph'], {})
	assert_eq((result['errors'] as Array).size(), 3)
