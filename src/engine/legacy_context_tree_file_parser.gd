class_name LegacyContextTreeFileParser

static func parse(file_path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		pass # TODO how to handle this?
	var result = _parser_file(file.get_as_text())
	file.close()
	return result

static func _parser_file(file_content: String) -> Dictionary:
	var data = JSON.parse_string(file_content)
	if data:
		var result = _parse_choice_state_machine(data['states'])
		# [TODO] parse other aspects of the file: deterministic and other game types
		return result
	return {
		"errors": ["unable to parse the JSON object"]
	}

static func _parse_choice_state_machine(choice_state_machine_lines: Array) \
	-> Dictionary:
	var parsed_lines = []
	var errors = []
	for i in choice_state_machine_lines.size():
	#for line in choice_state_machine_lines:
		var line = choice_state_machine_lines[i]
		var result = _parse_choice_state_machine_line(line)
		parsed_lines.append(result)
		for e in result['errors']:
			errors.append(('In "states" element %s: ' + e) % i)
	
	if errors.size():
		return {
			"contexts_and_probabilities": [],
			"errors": errors
		}
	
	return {
		"contexts_and_probabilities": parsed_lines,
		"errors": errors
	}

static func _parse_choice_state_machine_line(choice_state_machine_line: 
	Dictionary) -> Dictionary:
	var splitted_path = choice_state_machine_line['path'].split()
	var final_path_list = []
	for i in splitted_path.size():
		if splitted_path[i] == "0":
			final_path_list.append('LEFT')
		elif splitted_path[i] == "1":
			final_path_list.append("CENTER")
		elif splitted_path[i] == "2":
			final_path_list.append("RIGHT")
	var context = ">".join(final_path_list)
	
	var probability_left = float(choice_state_machine_line["probEvent0"])
	var probability_center = float(choice_state_machine_line["probEvent1"])
	
	var errors: Array
	if probability_left + probability_center > 1.0:
		errors.append('probabilities sum > 1.0')
	if probability_left < 0.0:
		errors.append('probability %s < 0.0' % probability_left)
	if probability_center < 0.0:
		errors.append('probability %s < 0.0' % probability_center)
	
	return {
		"context": context,
		"probabilities": [probability_left, probability_center],
		"errors": errors
	}
