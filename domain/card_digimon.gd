class_name CardDigimon extends Card

var color: COLORS
var attackPoints: int
var healthPoints: int
var energyCount: int
var evolution: String
var level: int
	
func _init(card_data):
	color = card_data.color
	attackPoints = card_data.attackPoints
	healthPoints = card_data.healthPoints
	energyCount = card_data.energyCount
	evolution = card_data.evolution
	level = card_data.level
