class_name Player
extends Node

signal async_action(action: String)

@onready var is_active: bool = false
@onready var sub_vierport: SubViewport = $SubViewportContainer/SubViewport
@onready var sprite: AnimatedSprite2D = $SubViewportContainer/AnimatedSprite2D

# [TODO] refactor: use "choice" for choices, and action to [choice, choice_metadata]

func _unhandled_input(event: InputEvent) -> void:
	var action: String
	
	if self.is_active:
		if event.is_action_pressed('left'):
			action = 'LEFT'
		elif event.is_action_pressed("center"):
			action = 'CENTER'
		elif event.is_action_pressed('right'):
			action = 'RIGHT'

	if action:
		sub_vierport.set_input_as_handled()
		async_action.emit(action)

func _ready() -> void:
	# Running this scene isolated (F6) 
	# 	plays 5 consecutive turns
	if _is_root_scene():
		_play_demo()

func _is_root_scene() -> bool:
	return self == get_tree().root.get_child(0)
	
func _play_demo():
	var choice
	for i in range(0, 5):
		choice = (await play_turn())[0] # [choice, response_time]
		await play_animation(choice)
	get_tree().quit()

func play_turn() -> Array:
	$Stopwatch.reset()
	is_active = true
	$Stopwatch.start()
	var action = await async_action
	$Stopwatch.stop()
	self.is_active = false

	return [action, $Stopwatch.elapsed_time_in_us()]

func play_animation(action: String) -> void:
	if action == 'CENTER':
		sprite.animation = 'jump-center'
	else:
		sprite.animation = 'jump-side'
		sprite.flip_h = (action == 'LEFT')
	sprite.play()
	await sprite.animation_finished
	# reset
	sprite.animation = 'idle'
	sprite.play()
	await sprite.animation_finished

func pause() -> void:
	if is_active:
		$Stopwatch.stop()
	
func unpause() -> void:
	if is_active:
		$Stopwatch.start()
