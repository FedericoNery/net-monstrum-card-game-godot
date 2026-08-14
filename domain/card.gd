class_name Card

var id: String
var price: int
var name: String
var type: DB.CARD_TYPE
var description: String

func _init(card_data):
	id = card_data._id
	price = card_data.price
	name = card_data.name
	type = card_data.type
	description = card_data.get("description", "")
