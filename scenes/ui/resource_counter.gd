extends HBoxContainer
class_name ResourceCounter

@export var swatch_color: Color = Color(0, 0, 0, 0)
@export var title_text: String = ""

var count: int = 0

func _ready() -> void:
	$Swatch.color = swatch_color
	$Swatch.visible = swatch_color.a > 0
	$TitleLabel.text = title_text
	$TitleLabel.visible = title_text != ""
	_refresh()

func set_count(value: int) -> void:
	count = value
	_refresh()

func increment(amount: int = 1) -> void:
	set_count(count + amount)

func _refresh() -> void:
	$CountLabel.text = str(count)
