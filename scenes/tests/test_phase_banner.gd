extends Node2D

func _ready() -> void:
	$PhaseBanner.banner_finished.connect(_on_banner_finished)

func _on_banner_finished(phase_key: String) -> void:
	$UI/VBox/StatusLabel.text = "Última fase mostrada: " + phase_key

func _on_start_pressed() -> void:
	$PhaseBanner.show_phase("start")

func _on_draw_pressed() -> void:
	$PhaseBanner.show_phase("draw")

func _on_load_pressed() -> void:
	$PhaseBanner.show_phase("load")

func _on_summon_pressed() -> void:
	$PhaseBanner.show_phase("summon")

func _on_compile_pressed() -> void:
	$PhaseBanner.show_phase("compile")

func _on_battle_pressed() -> void:
	$PhaseBanner.show_phase("battle")
