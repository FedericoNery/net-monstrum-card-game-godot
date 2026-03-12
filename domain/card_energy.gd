class_name CardEnergy extends Card

var color: COLORS_CARD
var energyCount: int
	
func _init(card_data):
	color = card_data.color
	energyCount = card_data.energyCount
