extends Control
class_name ActionMenu

signal option_selected(option_id: String)

func _ready() -> void:
	visible = false

func set_prompt(text: String) -> void:
	$Frame/VBox/PromptLabel.text = text

func set_options(options: Array) -> void:
	for child in $Frame/VBox/Options.get_children():
		child.queue_free()
	for option in options:
		var btn := Button.new()
		btn.text = option.label
		btn.pressed.connect(func(): option_selected.emit(option.id))
		$Frame/VBox/Options.add_child(btn)

func show_menu() -> void:
	visible = true

func hide_menu() -> void:
	visible = false
