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
	var result = _parse_choice_state_machine(data['states'])
	# [TODO] parse other aspects of the file: deterministic and other game types
	return result

static func _parse_choice_state_machine(choice_state_machine_lines: Array) \
	-> Dictionary:
	var parsed_lines = []
	for line in choice_state_machine_lines:
		var result = _parse_choice_state_machine_line(line)
		parsed_lines.append(result)
		
	return {
		"contexts_and_probabilities": parsed_lines,
		"initial_context": null,
		"errors": []
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
	
	# [TODO] validate probability values
	
	return {
		"context": context,
		"probabilities": [probability_left, probability_center]
	}
