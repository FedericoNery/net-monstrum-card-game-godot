class_name CardEnergy extends Card

var color: COLORS
var energyCount: int
	
func _init(card_data):
	color = card_data.color
	energyCount = card_data.energyCount
