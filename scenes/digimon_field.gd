extends Node2D

const CARD_SCENE := preload("res://scenes/card.tscn")
const COMBO_MIN_COPIES := 3
const COMBO_BONUS_4PLUS := 0  # TBD: REGLAS_DE_NEGOCIO.md sección 7 no define el valor exacto del bonus de 4+

signal digimon_added(card_node: Node)
signal digimon_removed(card_node: Node)
signal combo_activated(card_id: String, copies_count: int, total_ap: int, total_hp: int, evolved_source: Variant)
signal combo_updated(card_id: String, copies_count: int, total_ap: int, total_hp: int)
signal combo_deactivated(card_id: String)

var field_cards: Array = []          # [{ "node": Card, "data": CardDigimon }]
var active_combos: Dictionary = {}   # card_id -> { "node": Node, "count": int }

func summon_digimon_to_field(card_data: CardDigimon) -> Node:
	var slot_index := field_cards.size()
	if slot_index >= $Slots.get_child_count():
		push_warning("DigimonField: no hay más slots libres en el campo")
		return null
	var card_node = CARD_SCENE.instantiate()
	card_node.set_card_data(card_data)
	card_node.set_interactive(false)
	$CardsContainer.add_child(card_node)
	card_node.position = $Slots.get_child(slot_index).position
	field_cards.append({"node": card_node, "data": card_data})
	digimon_added.emit(card_node)
	_check_combos()
	return card_node

func remove_digimon_from_field(card_node: Node) -> void:
	field_cards = field_cards.filter(func(e): return e.node != card_node)
	card_node.queue_free()
	digimon_removed.emit(card_node)
	_check_combos()

# --- Sincronización multiplayer (ver scenes/network_manager.gd) ---
# El host es la autoridad: cualquier peer puede pedir la acción, pero se
# ejecuta en todos (incluido quien la pidió) vía call_local para que el
# estado del campo quede idéntico en ambas instancias.

@rpc("any_peer", "call_local", "reliable")
func rpc_summon_digimon(card_id: String) -> void:
	var card_data := DB.get_card_by_id(card_id)
	if card_data == null or not (card_data is CardDigimon):
		push_warning("DigimonField.rpc_summon_digimon: id inválido para CardDigimon: %s" % card_id)
		return
	summon_digimon_to_field(card_data)

@rpc("any_peer", "call_local", "reliable")
func rpc_remove_digimon(field_index: int) -> void:
	if field_index < 0 or field_index >= field_cards.size():
		push_warning("DigimonField.rpc_remove_digimon: índice fuera de rango: %d" % field_index)
		return
	remove_digimon_from_field(field_cards[field_index].node)

func activate_program_card() -> void:
	pass  # fuera de alcance de este trabajo

# --- Prototipo mínimo de detección de combo (ver IMPLEMENTACION_GODOT.md sección 3:
# esto es un stand-in temporal, a extraer como ComboResolver propio cuando exista lógica real) ---
func _check_combos() -> void:
	var groups: Dictionary = {}
	for entry in field_cards:
		if not groups.has(entry.data.id):
			groups[entry.data.id] = []
		groups[entry.data.id].append(entry)

	for card_id in groups.keys():
		var group: Array = groups[card_id]
		if group.size() >= COMBO_MIN_COPIES:
			_activate_or_update_combo(card_id, group)
		elif active_combos.has(card_id):
			_deactivate_combo(card_id)

	for card_id in active_combos.keys():
		if not groups.has(card_id):
			_deactivate_combo(card_id)

func _sum_stats(group: Array) -> Dictionary:
	var total_ap := 0
	var total_hp := 0
	for entry in group:
		total_ap += entry.data.attackPoints
		total_hp += entry.data.healthPoints
	if group.size() >= 4:
		total_ap += COMBO_BONUS_4PLUS
		total_hp += COMBO_BONUS_4PLUS
	return {"ap": total_ap, "hp": total_hp}

func _centroid(group: Array) -> Vector2:
	var sum := Vector2.ZERO
	for entry in group:
		sum += entry.node.position
	return sum / group.size()

func _activate_or_update_combo(card_id: String, group: Array) -> void:
	var totals := _sum_stats(group)
	if active_combos.has(card_id):
		var overlay = active_combos[card_id].node
		if overlay.has_method("update_stats_display"):
			overlay.update_stats_display(totals.ap, totals.hp)
		active_combos[card_id].count = group.size()
		combo_updated.emit(card_id, group.size(), totals.ap, totals.hp)
		return

	var source_data: CardDigimon = group[0].data
	var evolved_source = DB.get_card_by_id(source_data.evolution) if source_data.evolution != null else null

	if evolved_source != null and evolved_source is CardDigimon:
		var overlay = _spawn_evolution_overlay(evolved_source, totals, _centroid(group))
		active_combos[card_id] = {"node": overlay, "count": group.size()}
	else:
		var badge = _spawn_combo_badge(totals, _centroid(group))
		active_combos[card_id] = {"node": badge, "count": group.size()}

	combo_activated.emit(card_id, group.size(), totals.ap, totals.hp, evolved_source)

func _deactivate_combo(card_id: String) -> void:
	var overlay = active_combos[card_id].node
	var tween := create_tween()
	tween.tween_property(overlay, "modulate:a", 0.0, 0.3)
	tween.tween_callback(overlay.queue_free)
	active_combos.erase(card_id)
	combo_deactivated.emit(card_id)

func _spawn_evolution_overlay(evolved_source: CardDigimon, totals: Dictionary, spawn_position: Vector2) -> Node:
	var display_data := CardDigimon.new({
		"_id": evolved_source.id,
		"price": evolved_source.price,
		"name": evolved_source.name,
		"color": evolved_source.color,
		"attackPoints": totals.ap,
		"healthPoints": totals.hp,
		"energyCount": evolved_source.energyCount,
		"evolution": evolved_source.evolution,
		"type": evolved_source.type,
		"level": evolved_source.level,
	})
	var overlay = CARD_SCENE.instantiate()
	overlay.set_card_data(display_data)
	overlay.set_interactive(false)
	$ComboOverlays.add_child(overlay)
	overlay.position = spawn_position + Vector2(0, -60)
	overlay.flip_animation_finished.connect(func():
		var tween := create_tween()
		tween.tween_property(overlay, "modulate:a", 0.55, 0.4)
	, CONNECT_ONE_SHOT)
	return overlay

func _spawn_combo_badge(totals: Dictionary, spawn_position: Vector2) -> Node:
	var label := Label.new()
	label.text = "COMBO  %d/%d" % [totals.ap, totals.hp]
	label.position = spawn_position + Vector2(-60, -80)
	label.modulate.a = 0.0
	$ComboOverlays.add_child(label)
	var tween := create_tween()
	tween.tween_property(label, "modulate:a", 1.0, 0.3)
	tween.tween_interval(0.9)
	tween.tween_property(label, "modulate:a", 0.55, 0.4)
	return label
