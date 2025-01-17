class_name ContextTreeCsvParser

static func parse(file_path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		pass # TODO how to handle this?
	return _parse_csv(file.get_as_text())

static func _parse_csv(file_content: String) -> Dictionary:
	const initial_context_already_declared_template = \
		"In line %s: initial context already declared in previous line"
	var errors: Array = []
	var parsed_lines: Array = []
	var initial_context = null
	
	var lines = file_content.split('\n').slice(1) # skip CSV header
	for i in lines.size():
		if (lines[i] as String).is_empty():
			continue
		var parsed_line = _parse_line(i, lines[i] as String)
		if (parsed_line['errors'] as Array).size():
			errors += parsed_line['errors']
		else:
			if parsed_line['is_initial_context']:
				if initial_context == null:
					initial_context = parsed_line['context']
				else:
					errors += [initial_context_already_declared_template % i]
			parsed_lines.append(parsed_line)
	
	return {
		"contexts_and_probabilities": parsed_lines \
			if not errors.size() else [],
		"initial_context": initial_context,
		"errors": errors
	}

static func _parse_line(line_number: int, line: String) -> Dictionary:
	var line_errors: Array = []
	
	var result = _parse_values(line.split(','))
	var errors = result['errors'] as Array
	if errors.size() > 0:
		const error_on_line_template = "In line %s: %s"
		for e in errors:
			line_errors.append(error_on_line_template % [line_number + 1, e])
	return {
		"context": result['context'],
		"is_initial_context": result['is_initial_context'],
		"probabilities": result['probabilities'],
		"errors": line_errors
	}

static func _parse_values(values: Array) -> Dictionary:
	var errors = []
	
	if values.size() != 3:
		const line_values_size_template = 'exactly 3 values expected; %s (%s) given'
		errors.append(line_values_size_template % \
			[values.size(), values])
	
	var context = _parse_context(values[0] as String)
	var probabilities = _parse_probabilities(values.slice(1))
	errors.append_array(context['errors'] as Array)
	errors.append_array(probabilities['errors'] as Array)
	
	if errors.size() > 0:
		return { "errors": errors, "context": null,
			"is_initial_context": false, "probabilities": [] }
	return {
		"errors": errors,
		"context": context['context'],
		"is_initial_context": context['is_initial_context'],
		"probabilities": probabilities['probabilities']
	}

static func _parse_context(raw_context: String) -> Dictionary:
	# [TODO] add ref to troubleshooting page about this particular error
	const not_valid_context_template = "\"%s\" is not a valid context " \
		+ "(\"LEFT\", \"CENTER\" or \"RIGHT\"); check your spelling"
	
	var is_initial_context = false
	var stripped_context = raw_context.to_upper().replace(' ', '')
	if stripped_context.begins_with('*'):
		is_initial_context = true
		stripped_context = stripped_context.substr(1)
	
	var errors: Array = []
	var context_fragments = stripped_context.split('>')
	for fragment in context_fragments:
		if _is_not_valid_context(fragment):
			errors.append(not_valid_context_template % fragment)
	
	if errors.size() > 0:
		return { "errors": errors, "context": null, "is_initial_context": false }
	return { "errors": [],
		"context": '>'.join(PackedStringArray(context_fragments)),
		"is_initial_context": is_initial_context }

static func _is_not_valid_context(context_fragment: String) -> bool:
	return context_fragment != 'LEFT' \
		and context_fragment != 'CENTER' \
		and context_fragment != 'RIGHT'

static func _parse_probabilities(raw_probabilities: Array) -> Dictionary:
	# [TODO] add ref to troubleshooting page about this particular error
	# 	with reminder that 1.0 is the max, not 100%
	
	var probabilities_size_errors = \
		_validate_probabilities_size(raw_probabilities)["errors"] as Array
	if probabilities_size_errors.size():
		return { "probabilities": [], "errors": probabilities_size_errors }
	
	const probability_sum_gt_one_template = "sum of probabilities > 1.0"
	
	var errors: Array = []
	var sum: float = .0
	var rounded_probabilities: Array = []
	const precision: float = .000_001
	for i in raw_probabilities.size():
		var result = _parse_probability(raw_probabilities[i])
		var probability = result['probability']
		if probability == null:
			errors.append_array(result['errors'])
		else:
			sum += probability
			if sum > 1.0:
				errors.append(probability_sum_gt_one_template)
			rounded_probabilities.append(snappedf(probability, precision))
	return {
		"errors": errors,
		"probabilities": rounded_probabilities if errors.size() == 0 else []
	}

static func _validate_probabilities_size(raw_probabilities: Array) -> Dictionary:
	const probability_values_size_template = \
		"exactly 2 probability values are expected; %s (%s) given"
	var errors = []
	if raw_probabilities.size() != 2:
		errors.append(probability_values_size_template % \
			[raw_probabilities.size(), raw_probabilities])
	return { "errors": errors }

static func _parse_probability(probability_str: String) -> Dictionary:
	const probability_not_a_number_template = "\"%s\" is not a number"
	const probability_lt_zero_template = "%s < 0.0"
	const probability_gt_one_template = "%s > 1.0"
	
	var errors = []
	var probability = str_to_var(probability_str)
	if probability == null:
		errors.append(probability_not_a_number_template % probability_str)
	elif probability < 0.0:
		errors.append(probability_lt_zero_template % probability)
	elif probability > 1.0:
		errors.append(probability_gt_one_template % probability)
	
	return { 
		"probability": probability if errors.size() == 0 else null,
		"errors": errors
	}
