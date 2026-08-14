extends GutTest

const TEST_DECK_FILE := "gut_test_deck_tmp"

func after_each() -> void:
	DeckRepository.delete_deck(TEST_DECK_FILE)

func test_save_then_load_round_trip() -> void:
	var ids := []
	for i in range(40):
		ids.append("664e8b7ceb0218b7c40ce0a1")
	var original := Deck.new("Mazo de Prueba", ids)

	var err := DeckRepository.save_deck(original, TEST_DECK_FILE)
	assert_eq(err, OK)

	var loaded := DeckRepository.load_deck(TEST_DECK_FILE)
	assert_not_null(loaded)
	assert_eq(loaded.deck_name, original.deck_name)
	assert_eq(loaded.card_ids, original.card_ids)

func test_list_decks_includes_saved_file() -> void:
	var deck := Deck.new("Listado", [])
	DeckRepository.save_deck(deck, TEST_DECK_FILE)
	var decks := DeckRepository.list_decks()
	assert_true(decks.has(TEST_DECK_FILE + ".json"))

func test_load_missing_deck_returns_null() -> void:
	var loaded := DeckRepository.load_deck("no_deberia_existir_jamas")
	assert_null(loaded)

func test_delete_deck_removes_file() -> void:
	var deck := Deck.new("Borrar", [])
	DeckRepository.save_deck(deck, TEST_DECK_FILE)
	var err := DeckRepository.delete_deck(TEST_DECK_FILE)
	assert_eq(err, OK)
	assert_null(DeckRepository.load_deck(TEST_DECK_FILE))
