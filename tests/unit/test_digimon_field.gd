extends GutTest

const AGUMON_ID := "664e8b7ceb0218b7c40ce0a1"

var field

func before_each() -> void:
	field = load("res://scenes/digimon_field.tscn").instantiate()
	add_child_autofree(field)

func test_summon_adds_card_to_field() -> void:
	var agumon: CardDigimon = DB.get_card_by_id(AGUMON_ID)
	var node := field.summon_digimon_to_field(agumon)
	assert_not_null(node)
	assert_eq(field.field_cards.size(), 1)

func test_summon_respects_slot_limit() -> void:
	var agumon: CardDigimon = DB.get_card_by_id(AGUMON_ID)
	var slot_count: int = field.get_node("Slots").get_child_count()
	for i in range(slot_count):
		field.summon_digimon_to_field(agumon)
	assert_eq(field.field_cards.size(), slot_count)

	var overflow := field.summon_digimon_to_field(agumon)
	assert_null(overflow)
	assert_eq(field.field_cards.size(), slot_count)

func test_combo_activates_at_three_copies() -> void:
	watch_signals(field)
	var agumon: CardDigimon = DB.get_card_by_id(AGUMON_ID)
	field.summon_digimon_to_field(agumon)
	field.summon_digimon_to_field(agumon)
	assert_signal_not_emitted(field, "combo_activated")
	field.summon_digimon_to_field(agumon)
	assert_signal_emitted(field, "combo_activated")

func test_combo_deactivates_when_dropping_below_threshold() -> void:
	watch_signals(field)
	var agumon: CardDigimon = DB.get_card_by_id(AGUMON_ID)
	field.summon_digimon_to_field(agumon)
	field.summon_digimon_to_field(agumon)
	var third_node := field.summon_digimon_to_field(agumon)
	assert_signal_emitted(field, "combo_activated")

	field.remove_digimon_from_field(third_node)
	assert_signal_emitted(field, "combo_deactivated")

func test_remove_digimon_from_field_clears_entry() -> void:
	var agumon: CardDigimon = DB.get_card_by_id(AGUMON_ID)
	var node := field.summon_digimon_to_field(agumon)
	field.remove_digimon_from_field(node)
	assert_eq(field.field_cards.size(), 0)
