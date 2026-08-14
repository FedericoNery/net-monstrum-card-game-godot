class_name CardEnergy extends Card

var color: DB.COLORS_CARD
var energyCount: int
	
func _init(card_data):
	super._init(card_data)
	color = card_data.color
	energyCount = card_data.energyCount
	description = _build_description()

func _build_description() -> String:
	var color_name := ""
	match color:
		DB.COLORS_CARD.RED: color_name = "roja"
		DB.COLORS_CARD.BLUE: color_name = "azul"
		DB.COLORS_CARD.GREEN: color_name = "verde"
		DB.COLORS_CARD.WHITE: color_name = "blanca"
		DB.COLORS_CARD.BLACK: color_name = "negra"
		DB.COLORS_CARD.BROWN: color_name = "marrón"

	if energyCount >= 0:
		return "Otorga %d punto(s) de S-Energy %s." % [energyCount, color_name]
	return "Resta %d punto(s) de S-Energy %s al rival." % [abs(energyCount), color_name]
