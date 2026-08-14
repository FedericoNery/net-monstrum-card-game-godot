extends CanvasLayer
class_name PhaseBanner

signal banner_finished(phase_key: String)

const PHASE_LABELS := {
	"start": "START PHASE",
	"draw": "DRAW PHASE",
	"load": "LOAD PHASE",
	"summon": "SUMMON PHASE",
	"compile": "COMPILE PHASE",
	"battle": "BATTLE PHASE",
}

func show_phase(phase_key: String, hold_time: float = 1.2) -> void:
	$Root/BannerBg/PhaseLabel.text = PHASE_LABELS.get(phase_key, phase_key.to_upper())
	$Root/BannerBg.modulate.a = 0.0
	$Root/BannerBg.scale = Vector2(0.8, 0.8)
	var tween := create_tween()
	tween.tween_property($Root/BannerBg, "modulate:a", 1.0, 0.25)
	tween.parallel().tween_property($Root/BannerBg, "scale", Vector2.ONE, 0.25)
	tween.tween_interval(hold_time)
	tween.tween_property($Root/BannerBg, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): banner_finished.emit(phase_key))
