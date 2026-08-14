extends Node2D

func _on_energy_plus_pressed() -> void:
	$UI/VBox/Row1/EnergyRed.increment(1)

func _on_energy_minus_pressed() -> void:
	$UI/VBox/Row1/EnergyRed.increment(-1)

func _on_hand_plus_pressed() -> void:
	$UI/VBox/Row2/HandCounter.increment(1)

func _on_hand_minus_pressed() -> void:
	$UI/VBox/Row2/HandCounter.increment(-1)

func _on_deck_plus_pressed() -> void:
	$UI/VBox/Row3/DeckCounter.increment(1)

func _on_deck_minus_pressed() -> void:
	$UI/VBox/Row3/DeckCounter.increment(-1)
