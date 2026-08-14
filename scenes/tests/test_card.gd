extends Node2D

func _ready() -> void:
	var card_scene = preload("res://scenes/card.tscn")

	var greymon_card = card_scene.instantiate()
	greymon_card.set_card_data(DB.get_card_by_id("664e8b7ceb0218b7c40ce0a2"))
	greymon_card.position = Vector2(1160, 345)
	add_child(greymon_card)

	#var program_card = card_scene.instantiate()
	#program_card.set_card_data(DB.get_card_by_id("664e8b7ceb0218b7c40ce0e5"))
	#program_card.position = Vector2(1460, 345)
	#add_child(program_card)
