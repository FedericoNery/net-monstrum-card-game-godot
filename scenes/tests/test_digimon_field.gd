extends Node2D

var last_added: Node = null

func _ready() -> void:
	$DigimonField.combo_activated.connect(_on_combo_activated)
	$DigimonField.combo_updated.connect(_on_combo_updated)
	$DigimonField.combo_deactivated.connect(_on_combo_deactivated)

func _add_agumon() -> void:
	last_added = $DigimonField.summon_digimon_to_field(DB.get_card_by_id("664e8b7ceb0218b7c40ce0a1"))

func _on_add_one_pressed() -> void:
	_add_agumon()

func _on_add_three_pressed() -> void:
	for i in range(3):
		_add_agumon()

func _on_add_fourth_pressed() -> void:
	_add_agumon()

func _on_remove_last_pressed() -> void:
	if last_added != null and is_instance_valid(last_added):
		$DigimonField.remove_digimon_from_field(last_added)
		last_added = null

func _on_combo_activated(card_id, count, ap, hp, evolved_source) -> void:
	$UI/StatusLabel.text = "Combo activo: %s x%d, AP %d / HP %d" % [card_id, count, ap, hp]

func _on_combo_updated(card_id, count, ap, hp) -> void:
	$UI/StatusLabel.text = "Combo actualizado: %s x%d, AP %d / HP %d" % [card_id, count, ap, hp]

func _on_combo_deactivated(card_id) -> void:
	$UI/StatusLabel.text = "Combo desactivado: " + card_id
