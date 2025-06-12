extends Node2D

const HAND_COUNT = 6
const CARD_SCENE_PATH = "res://scenes/card.tscn"
const CARD_WIDTH = 200
const HAND_Y_POSITION = 700
var center_screen_x
var player_hand = []

func _ready() -> void:
	center_screen_x = get_viewport().size.x / 2
	var card_scene = preload(CARD_SCENE_PATH)
	for i in range(HAND_COUNT):
		var new_card = card_scene.instantiate()
		$".".add_child(new_card)
		add_card_to_hand(new_card)
		
func add_card_to_hand(card):
	player_hand.insert(0, card)
	update_hand_positions()

func update_hand_positions():
	for i in range(player_hand.size()):
		var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card = player_hand[i]
		animate_card_position(card, new_position)
		
		
func calculate_card_position(index):
	var total_width = (player_hand.size() - 1) * CARD_WIDTH
	var x_offset = center_screen_x + index * CARD_WIDTH - total_width / 2
	return x_offset
	
func animate_card_position(card, new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.3)
