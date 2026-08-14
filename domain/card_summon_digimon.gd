class_name CardSummonDigimon extends Card
var digimonsCards: Array
var digimon_name: String

func _init(card_data):
	digimonsCards = card_data.digimonsCards
	digimon_name = digimonsCards[0].name if not digimonsCards.is_empty() else "Digimon"
	description = "Invoca %d %s al campo sin gastar energía." % [digimonsCards.size(), digimon_name]
