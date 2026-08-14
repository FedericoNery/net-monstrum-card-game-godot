extends Control
class_name CardTooltip

func _ready() -> void:
	visible = false

func show_for(card_data: Card, near_position: Vector2) -> void:
	$Frame/VBox/DescriptionLabel.text = card_data.description
	$Frame/VBox/NameLabel.text = card_data.name
	$Frame.position = near_position
	visible = true

func hide_tooltip() -> void:
	visible = false
