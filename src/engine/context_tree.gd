class_name ContextTree

var graph: Dictionary
var initial_context = null
var current_context: String

func initialize(context_tree_file_path: String) -> Dictionary:
	var parser_result = ContextTreeCsvParser.parse(context_tree_file_path)
	var parsing_errors = parser_result['errors'] as Array
	if parsing_errors.size() > 0:
		return { "errors": parser_result['errors'] }
	
	var initial_context_ = parser_result['initial_context']
	var unchecked_context_tree = _build_context_tree_graph(
		parser_result['contexts_and_probabilities'])
	
	parsing_errors = (unchecked_context_tree['errors'] as Array)
	if parsing_errors.size():
		return { "errors": parsing_errors }
	
	var context_tree = _validate_graph(initial_context_, unchecked_context_tree['graph'])
	var semantic_errors = context_tree['errors'] as Array
	if semantic_errors.size():
		return { "errors": semantic_errors }
	
	graph = context_tree['graph']
	initial_context = initial_context_
	current_context = initial_context \
		if initial_context else _get_random_context(randi(), graph)
	return { "errors": [] }

func get_action() -> Array:
	var random_variable = randf()
	var action = ContextTree._get_action_from_random_variable(
		random_variable, graph, current_context
	)
	var choice = action[0]
	var probability = action[2]
	var current_context_ = current_context
	current_context = ContextTree._get_next_context(
		graph, current_context, choice)
	return [choice, current_context_, probability]

static func _get_random_context(random_variable: int, context_tree_graph: Dictionary):
	var contexts = context_tree_graph.keys()
	return contexts[random_variable % contexts.size()]

static func _build_context_tree_graph(contexts_and_probabilities: Array) -> Dictionary:
	var errors: Array = []
	var probabilities_by_context: Dictionary
	for i in contexts_and_probabilities.size():
		var context = contexts_and_probabilities[i]['context']
		var probabilities = contexts_and_probabilities[i]['probabilities']
		if context in probabilities_by_context.keys():
			errors.append("In line %s: context \"%s\" is already defined in a previous line")
		else:
			probabilities_by_context[context] = {
				"LEFT": probabilities[0], "CENTER": probabilities[1]
			}
	var graph_ = probabilities_by_context if errors.size() == 0 else {}
	return { "graph": graph_, "errors": errors }

static func _validate_graph(initial_context_, graph_: Dictionary) -> Dictionary:
	# 'initial_context': String or null
	var errors = []
	
	var queue: Array
	if initial_context_ == null:
		queue = graph_.keys() # consider any context as initial
	else:
		if initial_context_ not in graph_.keys():
			errors.append(
				"initial context \"%s\" is not connected to any other node" \
					% initial_context_)
			return { "graph": {}, "errors": errors }
		queue = [initial_context_]
	
	var visited: Array = []
	while queue.size():
		var context = queue.pop_front()
		if context in visited:
			continue
		
		if not graph_.has(context):
			var message = "context \"%s\" does not define probabilities" \
				% context
			if initial_context_ != null:
				message += " for initial context \"%s\"" % initial_context_
			errors.append(message)
			continue
		
		visited.append(context)
		var probabilities_by_choice = graph_[context]
		
		var probability_sum: float = .0
		var probablity_left = probabilities_by_choice['LEFT']
		if probablity_left > .0:
			probability_sum += probablity_left
			queue.push_front(_get_next_context(graph_, context, 'LEFT'))
		
		var probability_center = probabilities_by_choice['CENTER']
		if probability_center > .0:
			probability_sum += probability_center
			queue.push_front(_get_next_context(graph_, context, 'CENTER'))
		
		var probability_right = 1.0 - probability_sum
		if probability_right > .0:
			queue.push_front(_get_next_context(graph_, context, 'RIGHT'))
	
	var contexts = graph_.keys()
	for c in contexts:
		if c not in visited:
			errors.append(
				"context \"%s\" is not reacheable given initial context \"%s\"" \
					% [c, initial_context_])
	return { 
		"graph": graph_ if errors.size() == 0 else {},
		"errors": errors
	}

static func _get_next_context(
	context_tree: Dictionary, current_context_: String, choice: String) -> String:
	var next_context_guess = "%s>%s" % [current_context_, choice]
	if next_context_guess in context_tree.keys():
		return next_context_guess
	else:
		var context_path = current_context_.split(">")
		if context_path.size() > 1:
			return _get_next_context(
				context_tree, current_context_.get_slice(">", 1), choice)
		else:
			return choice

static func _get_action_from_random_variable(
	random_variable: float, context_tree_graph: Dictionary,
	current_context_: String) -> Array:
	const error = .00_005 # .005%
	assert(random_variable >= error)
	
	var choices_with_probabilities = context_tree_graph[current_context_]
	var complement = 1.0
	for choice in choices_with_probabilities.keys():
		var probability = choices_with_probabilities[choice]
		if probability != null:
			random_variable -= probability
			if random_variable < error:
				return [choice, current_context_, probability]
			else:
				complement -= probability
	
	# if the previous loop doesn't `return`, `choice` has 
	#	to be the omitted complementary term assuming a 
	#	`context_tree` with a valid semantic
	return ["RIGHT", current_context_, complement]
