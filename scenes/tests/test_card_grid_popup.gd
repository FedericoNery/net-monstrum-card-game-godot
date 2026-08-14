extends Node2D

func _ready() -> void:
	$UI/CardGridPopup.card_selected.connect(_on_card_selected)

func _on_view_hand_pressed() -> void:
	var cards = []
	for i in range(6):
		cards.append(DB.CARDS_DATA[i])
	$UI/CardGridPopup.open("Tu Mano", cards, {"selectable": false, "face_up": true})

func _on_search_deck_pressed() -> void:
	var cards = []
	for i in range(15):
		cards.append(DB.CARDS_DATA[i])
	$UI/CardGridPopup.open("Elegí una carta del Mazo", cards, {"selectable": true, "face_up": true})

func _on_card_selected(card_data: Card) -> void:
	$UI/StatusLabel.text = "Carta elegida: " + card_data.name
