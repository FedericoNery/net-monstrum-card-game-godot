extends Node2D

func _ready() -> void:
	$UI/ActionMenu.option_selected.connect(_on_option_selected)

func _on_simulate_pressed() -> void:
	$UI/ActionMenu.set_prompt("¿Deseas invocar un Digimon?")
	$UI/ActionMenu.set_options([
		{"id": "summon", "label": "Invocar Digimon"},
		{"id": "pass", "label": "Pasar"},
	])
	$UI/ActionMenu.show_menu()

func _on_option_selected(option_id: String) -> void:
	$UI/StatusLabel.text = "Última opción elegida: " + option_id
