extends Node2D

func _ready() -> void:
	var decks := [_build_deck_agumon_line(), _build_deck_gatomon_line()]
	var lines: Array[String] = []
	for deck in decks:
		var errors := deck.validate()
		if not errors.is_empty():
			lines.append("%s: INVALIDO -> %s" % [deck.deck_name, ", ".join(errors)])
			continue
		var err := DeckRepository.save_deck(deck)
		lines.append("%s: guardado (%s)" % [deck.deck_name, "OK" if err == OK else error_string(err)])

	lines.append("Mazos en user://decks/: %s" % ", ".join(DeckRepository.list_decks()))
	$Status.text = "\n".join(lines)

func _build_deck_agumon_line() -> Deck:
	var digimon_ids := [
		"664e8b7ceb0218b7c40ce0a1", # Agumon
		"664e8b7ceb0218b7c40ce0a2", # Greymon
		"664e8b7ceb0218b7c40ce0a5", # Gabumon
		"664e8b7ceb0218b7c40ce0a6", # Garurumon
		"664e8b7ceb0218b7c40ce0a9", # Veemon
		"664e8b7ceb0218b7c40ce0aa", # ExVeemon
		"664e8b7ceb0218b7c40ce0ad", # Patamon
		"664e8b7ceb0218b7c40ce0ae", # Angemon
	]
	var equipment_ids := [
		"664e8b7ceb0218b7c40ce0e5", # Armor +10
		"664e8b7ceb0218b7c40ce0e6", # Sword +10
	]
	return Deck.new("mazo_agumon_line", _repeat_each(digimon_ids, 4) + _repeat_each(equipment_ids, 4))

func _build_deck_gatomon_line() -> Deck:
	var digimon_ids := [
		"664e8b7ceb0218b7c40ce0b1", # Salamon
		"664e8b7ceb0218b7c40ce0b2", # Gatomon
		"664e8b7ceb0218b7c40ce0b5", # Biyomon
		"664e8b7ceb0218b7c40ce0b6", # Birdramon
		"664e8b7ceb0218b7c40ce0b9", # Tentomon
		"664e8b7ceb0218b7c40ce0ba", # Kabuterimon
		"664e8b7ceb0218b7c40ce0bd", # Palmon
		"664e8b7ceb0218b7c40ce0be", # Togemon
	]
	var energy_ids := [
		"664e8b7ceb0218b7c40ce0ee", # Red Energy +1
		"664e8b7ceb0218b7c40ce0ef", # Green Energy +1
	]
	return Deck.new("mazo_gatomon_line", _repeat_each(digimon_ids, 4) + _repeat_each(energy_ids, 4))

func _repeat_each(ids: Array, times: int) -> Array:
	var result: Array = []
	for id in ids:
		for i in range(times):
			result.append(id)
	return result
