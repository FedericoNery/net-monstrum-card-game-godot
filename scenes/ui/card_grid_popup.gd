extends CanvasLayer
class_name CardGridPopup

signal card_selected(card_data: Card)
signal closed

const CARD_SCENE := preload("res://scenes/card.tscn")
const CARD_BACK_SCENE := preload("res://scenes/card_back.tscn")
const SLOT_SIZE := Vector2(260, 400)

func _ready() -> void:
	visible = false

func open(title: String, cards: Array, opts: Dictionary = {}) -> void:
	var selectable: bool = opts.get("selectable", false)
	var face_up: bool = opts.get("face_up", true)
	$Root/Frame/VBox/TitleLabel.text = title
	_clear_grid()
	for card_data in cards:
		var slot := Control.new()
		slot.custom_minimum_size = SLOT_SIZE
		var visual: Node
		if face_up:
			visual = CARD_SCENE.instantiate()
			visual.set_card_data(card_data)
		else:
			visual = CARD_BACK_SCENE.instantiate()
		slot.add_child(visual)
		if face_up:
			visual.set_interactive(false)
		if selectable and face_up:
			var btn := Button.new()
			btn.flat = true
			btn.self_modulate = Color(1, 1, 1, 0)
			btn.mouse_filter = Control.MOUSE_FILTER_STOP
			btn.set_anchors_preset(Control.PRESET_FULL_RECT)
			btn.pressed.connect(func(): card_selected.emit(card_data); close())
			slot.add_child(btn)
		$Root/Frame/VBox/Scroll/CardsGrid.add_child(slot)
	visible = true

func close() -> void:
	visible = false
	closed.emit()

func _clear_grid() -> void:
	for child in $Root/Frame/VBox/Scroll/CardsGrid.get_children():
		child.queue_free()

func _on_backdrop_pressed() -> void:
	close()

func _on_close_button_pressed() -> void:
	close()
