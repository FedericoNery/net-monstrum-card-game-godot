extends GutTest

func test_get_card_by_id_finds_known_card() -> void:
	var card := DB.get_card_by_id("664e8b7ceb0218b7c40ce0a1")
	assert_not_null(card)
	assert_eq(card.name, "Agumon")

func test_get_card_by_id_returns_null_for_unknown_id() -> void:
	var card := DB.get_card_by_id("esto-no-existe")
	assert_null(card)

func test_cards_data_has_no_duplicate_ids() -> void:
	# Bug conocido (ver SPEC.md §8): varios _id se repiten en DB.CARDS_DATA.
	# Este test queda en rojo a propósito hasta que se deduplique la base de datos;
	# sirve de regresión para cuando eso se corrija.
	var seen := {}
	var duplicates := []
	for card in DB.CARDS_DATA:
		if seen.has(card.id):
			duplicates.append(card.id)
		seen[card.id] = true
	assert_eq(duplicates, [], "hay ids duplicados en CARDS_DATA: %s" % [duplicates])
