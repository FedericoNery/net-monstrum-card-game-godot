class_name CardEquipment extends Card
var attackPoints: int
var healthPoints: int
var targetScope: String
var quantityOfTargets: int
	
func _init(card_data):
	attackPoints = card_data.attackPoints
	healthPoints = card_data.healthPoints
	targetScope = card_data.targetScope
	quantityOfTargets = card_data.quantityOfTargets
