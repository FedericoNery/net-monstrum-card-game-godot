extends GutTest

const VALID_ID := "664e8b7ceb0218b7c40ce0a1" # Agumon, existe en DB.CARDS_DATA

func _make_ids(id: String, count: int) -> Array:
	var ids := []
	for i in range(count):
		ids.append(id)
	return ids

func test_valid_deck_has_no_errors() -> void:
	var ids := []
	# 10 cartas distintas x 4 copias = 40, todas dentro del límite
	var known_ids := [
		"664e8b7ceb0218b7c40ce0a1", "664e8b7ceb0218b7c40ce0a2",
		"664e8b7ceb0218b7c40ce0a5", "664e8b7ceb0218b7c40ce0a6",
		"664e8b7ceb0218b7c40ce0a9", "664e8b7ceb0218b7c40ce0aa",
		"664e8b7ceb0218b7c40ce0ad", "664e8b7ceb0218b7c40ce0ae",
		"664e8b7ceb0218b7c40ce0b1", "664e8b7ceb0218b7c40ce0b2",
	]
	for id in known_ids:
		ids += _make_ids(id, 4)

	var deck := Deck.new("test_deck", ids)
	assert_eq(deck.validate(), [], "un mazo de 40 cartas válidas no debería tener errores")
	assert_true(deck.is_valid())

func test_wrong_card_count_fails() -> void:
	var deck := Deck.new("corto", _make_ids(VALID_ID, 39))
	var errors := deck.validate()
	assert_false(errors.is_empty())
	assert_true(errors[0].findn("40") != -1)

func test_too_many_copies_fails() -> void:
	var ids := _make_ids(VALID_ID, 5)
	# completar a 40 con otro id válido para aislar el error de "copias"
	ids += _make_ids("664e8b7ceb0218b7c40ce0a2", 35)
	var deck := Deck.new("clones", ids)
	var errors := deck.validate()
	assert_true(errors.any(func(e): return e.findn("copias") != -1))

func test_unknown_card_id_fails() -> void:
	var ids := _make_ids("id-que-no-existe", 40)
	var deck := Deck.new("fantasma", ids)
	var errors := deck.validate()
	assert_true(errors.any(func(e): return e.findn("no existe") != -1))

func test_count_copies() -> void:
	var deck := Deck.new("x", _make_ids(VALID_ID, 4) + _make_ids("otro-id", 36))
	assert_eq(deck.count_copies(VALID_ID), 4)
	assert_eq(deck.count_copies("id-inexistente"), 0)

func test_resolve_cards_returns_card_instances() -> void:
	var deck := Deck.new("x", _make_ids(VALID_ID, 40))
	var cards := deck.resolve_cards()
	assert_eq(cards.size(), 40)
	for card in cards:
		assert_true(card is Card)
