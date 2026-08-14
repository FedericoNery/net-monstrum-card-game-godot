class_name CardEquipment extends Card
var attackPoints: int
var healthPoints: int
var targetScope: String
var quantityOfTargets: Variant
	
func _init(card_data):
	super._init(card_data)
	attackPoints = card_data.attackPoints
	healthPoints = card_data.healthPoints
	targetScope = card_data.targetScope
	quantityOfTargets = card_data.quantityOfTargets
	description = _build_description()

func _build_description() -> String:
	var parts: Array[String] = []
	if attackPoints > 0:
		parts.append("+%d AP" % attackPoints)
	if healthPoints > 0:
		parts.append("+%d HP" % healthPoints)
	var bonus_text := " y ".join(parts) if not parts.is_empty() else "un bono"

	var target_text := ""
	match targetScope:
		"UNIQUE":
			target_text = "a un Digimon"
		"PARTIAL":
			target_text = "a %d Digimon" % quantityOfTargets
		"ALL":
			target_text = "a todos los Digimon"

	return "Otorga %s %s." % [bonus_text, target_text]
