extends Node2D

func _ready() -> void:
	var card_scene = preload("res://scenes/card.tscn")

	var digimon_card = card_scene.instantiate()
	digimon_card.set_card_data(DB.get_card_by_id("664e8b7ceb0218b7c40ce0a1"))
	digimon_card.position = Vector2(500, 400)
	digimon_card.card_selected.connect(_on_card_selected)
	add_child(digimon_card)

	#var program_card = card_scene.instantiate()
	#program_card.set_card_data(DB.get_card_by_id("664e8b7ceb0218b7c40ce0e5"))
	#program_card.position = Vector2(800, 400)
	#program_card.card_selected.connect(_on_card_selected)
	#add_child(program_card)

func _on_card_selected(card_data: Card, is_selected: bool) -> void:
	if is_selected:
		$UI/CardTooltip.show_for(card_data, Vector2(1100, 350))
	else:
		$UI/CardTooltip.hide_tooltip()
