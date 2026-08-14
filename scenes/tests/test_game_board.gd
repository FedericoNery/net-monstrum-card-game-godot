extends Node2D

var energy_p1_red := 0
var opponent_hand_count := 6

func _on_phase_start_pressed() -> void: $GameBoard.show_phase("start")
func _on_phase_draw_pressed() -> void: $GameBoard.show_phase("draw")
func _on_phase_load_pressed() -> void: $GameBoard.show_phase("load")
func _on_phase_summon_pressed() -> void: $GameBoard.show_phase("summon")
func _on_phase_compile_pressed() -> void: $GameBoard.show_phase("compile")
func _on_phase_battle_pressed() -> void: $GameBoard.show_phase("battle")

func _on_energy_plus_pressed() -> void:
	energy_p1_red += 1
	$GameBoard.set_energy(1, DB.COLORS_CARD.RED, energy_p1_red)

func _on_view_hand_pressed() -> void:
	$GameBoard.open_hand_viewer()

func _on_search_deck_pressed() -> void:
	var cards = []
	for i in range(15):
		cards.append(DB.CARDS_DATA[i])
	$GameBoard.open_deck_search(cards)

func _on_add_combo_pressed() -> void:
	for i in range(3):
		$GameBoard.player1_field.summon_digimon_to_field(DB.get_card_by_id("664e8b7ceb0218b7c40ce0a1"))

func _on_opponent_hand_plus_pressed() -> void:
	opponent_hand_count += 1
	$GameBoard.set_hand_count(2, opponent_hand_count)

func _on_opponent_hand_minus_pressed() -> void:
	opponent_hand_count = max(0, opponent_hand_count - 1)
	$GameBoard.set_hand_count(2, opponent_hand_count)

func _on_summon_menu_pressed() -> void:
	$GameBoard.show_action_menu("¿Deseas invocar un Digimon?", [
		{"id": "summon", "label": "Invocar"},
		{"id": "pass", "label": "Pasar"},
	])
