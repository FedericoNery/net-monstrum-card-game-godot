extends Node2D
class_name GameBoard

const COLOR_ORDER := [
	DB.COLORS_CARD.WHITE, DB.COLORS_CARD.BLUE, DB.COLORS_CARD.GREEN,
	DB.COLORS_CARD.RED, DB.COLORS_CARD.BLACK, DB.COLORS_CARD.BROWN,
]

const CARD_BACK_SCENE := preload("res://scenes/card_back.tscn")

@onready var player1_field := $Player1Field
@onready var player2_field := $Player2Field
@onready var player1_hand := $Player1Hand
@onready var player2_hand_row := $Player2HandRow
@onready var phase_banner := $UILayer/PhaseBanner
@onready var action_menu := $UILayer/ActionMenu
@onready var card_tooltip := $UILayer/CardTooltip
@onready var card_grid_popup := $UILayer/CardGridPopup

func _ready() -> void:
	for field in [player1_field, player2_field]:
		field.combo_activated.connect(_on_combo_activated)
		field.combo_deactivated.connect(_on_combo_deactivated)
	action_menu.option_selected.connect(_on_action_selected)

	for card_node in player1_hand.player_hand:
		card_node.card_selected.connect(_on_hand_card_selected)
		card_node.card_hovered.connect(_on_player1_card_hovered)
		card_node.card_unhovered.connect(_on_player1_card_unhovered)

	set_opponent_hand_count(6)

# --- Contadores (mock hoy; llamados a futuro desde EnergyTracker/Deck reales) ---

func set_energy(player: int, color: DB.COLORS_CARD, value: int) -> void:
	var bar_name := "TopBar" if player == 2 else "BottomBar"
	var counter_name := "Energy%d" % COLOR_ORDER.find(color)
	$UILayer.get_node(bar_name + "/" + counter_name).set_count(value)

func set_hand_count(player: int, value: int) -> void:
	var bar_name := "TopBar" if player == 2 else "BottomBar"
	$UILayer.get_node(bar_name + "/Hand").set_count(value)
	if player == 2:
		set_opponent_hand_count(value)

func set_trash_count(player: int, value: int) -> void:
	var counter_name := "TrashP2" if player == 2 else "TrashP1"
	$UILayer.get_node(counter_name).set_count(value)

func set_deck_count(player: int, value: int) -> void:
	var bar_name := "TopBar" if player == 2 else "BottomBar"
	$UILayer.get_node(bar_name + "/Deck").set_count(value)

func set_opponent_hand_count(value: int) -> void:
	for child in player2_hand_row.get_children():
		child.queue_free()
	for i in range(value):
		var back = CARD_BACK_SCENE.instantiate()
		back.position = Vector2(i * 130, 0)
		player2_hand_row.add_child(back)

# --- Fases / menú de acciones ---

func show_phase(phase_key: String) -> void:
	phase_banner.show_phase(phase_key)

func show_action_menu(prompt: String, options: Array) -> void:
	action_menu.set_prompt(prompt)
	action_menu.set_options(options)
	action_menu.show_menu()

func _on_action_selected(option_id: String) -> void:
	action_menu.hide_menu()
	print("Acción elegida (mock): ", option_id)

# --- Visualizadores de cartas ---

func open_hand_viewer() -> void:
	var cards = player1_hand.player_hand.map(func(c): return c.CardInformation)
	card_grid_popup.open("Tu Mano", cards, {"selectable": false, "face_up": true})

func open_deck_search(mock_deck_cards: Array) -> void:
	card_grid_popup.open("Elegí una carta del Mazo", mock_deck_cards, {"selectable": true, "face_up": true})

# --- Tooltip de carta (mano propia) ---

func _on_hand_card_selected(card_data: Card, is_selected: bool) -> void:
	if is_selected:
		card_tooltip.show_for(card_data, Vector2(700, 600))
	else:
		card_tooltip.hide_tooltip()

# --- Preview de AP/HP (solo mano propia; el campo usa cartas no interactivas
# y la mano rival está boca abajo, así que ese preview queda sin cablear por ahora) ---

func _on_player1_card_hovered(card_data: Card) -> void:
	if card_data is CardDigimon:
		$UILayer/BottomStatsPreview/AP.set_count(card_data.attackPoints)
		$UILayer/BottomStatsPreview/HP.set_count(card_data.healthPoints)

func _on_player1_card_unhovered() -> void:
	$UILayer/BottomStatsPreview/AP.set_count(0)
	$UILayer/BottomStatsPreview/HP.set_count(0)

# --- Combos (puntos de extensión a futuro) ---

func _on_combo_activated(card_id, count, ap, hp, evolved_source) -> void:
	pass

func _on_combo_deactivated(card_id) -> void:
	pass
