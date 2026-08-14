class_name Deck extends Resource

const REQUIRED_CARD_COUNT := 40
const MAX_COPIES_PER_CARD := 4

var deck_name: String = ""
var card_ids: Array[String] = []

func _init(p_name: String = "", p_card_ids: Array = []) -> void:
	deck_name = p_name
	card_ids = []
	for id in p_card_ids:
		card_ids.append(String(id))

func count_copies(card_id: String) -> int:
	var count := 0
	for id in card_ids:
		if id == card_id:
			count += 1
	return count

func validate() -> Array[String]:
	var errors: Array[String] = []

	if card_ids.size() != REQUIRED_CARD_COUNT:
		errors.append("El mazo debe tener exactamente %d cartas (tiene %d)." % [REQUIRED_CARD_COUNT, card_ids.size()])

	var seen: Dictionary = {}
	for id in card_ids:
		if seen.has(id):
			continue
		seen[id] = true
		var copies := count_copies(id)
		if copies > MAX_COPIES_PER_CARD:
			errors.append("La carta '%s' tiene %d copias (máximo %d)." % [id, copies, MAX_COPIES_PER_CARD])
		if DB.get_card_by_id(id) == null:
			errors.append("La carta '%s' no existe en DB.CARDS_DATA." % id)

	return errors

func is_valid() -> bool:
	return validate().is_empty()

func resolve_cards() -> Array[Card]:
	var cards: Array[Card] = []
	for id in card_ids:
		var card := DB.get_card_by_id(id)
		if card != null:
			cards.append(card)
	return cards
