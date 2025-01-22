extends HBoxContainer
class_name ItemListWithInfoOnRight

class DataItem:
	var text: String
	var info: String
	
	func _init(data: Dictionary) -> void:
		text = data['text']
		info = data['info']

var selected_item_idx: int = 0
var data: Array

signal selected(index: int)


func _ready() -> void:
	reset()
	if _is_root_scene():
		_play_demo()

func _is_root_scene() -> bool:
	return self == get_tree().root.get_child(0)

func _play_demo():
	load_(demo_data)


func load_(data_: Array) -> void: # TODO refactor into a custom "TypedArray"
	# 	data_: Array<DataItem>
	if data_.size() > 0:
		_load(data_)
	else:
		$Label.text = "DATA_ARRAY_IS_EMPTY"

func reset() -> void:
	data = []
	selected_item_idx = 0
	$ItemList.clear()

func _load(data_: Array) -> void:
	for d in data_:
		var item = DataItem.new(d)
		data.append(item)
		$ItemList.add_item(item.text)
	
	$ItemList.select(0)
	var info = (data[0] as DataItem).info
	_update_text_box(info)

# signal handling
func _on_item_list_item_selected(index: int) -> void:
	var item: DataItem = data[index] as DataItem
	_update_text_box(item.info)
	selected_item_idx = index
	selected.emit(index)

# helpers
func _update_text_box(info: String) -> void:
	$Label.text = info

# demo
const demo_data = [
	{
		'text': 'a_valid_context_tree.csv',
		'info': 'this tree is OK and selectable'
	},
	{
		'text': 'invalid_syntax_context_tree.csv',
		'info': 'INVALID tree\nIn line 2: "CENTRE" is not a context, check your spelling'
	},
	{
		'text': 'invalid_semantics_context_tree.csv',
		'info': 'INVALID tree\nIn line... <reason for being invalid>'
	},
	{
		'text': 'another_valid_example.csv',
		'info': 'VALID and selectable tree'
	}
]
