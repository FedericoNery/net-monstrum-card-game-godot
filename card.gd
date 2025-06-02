extends Node2D

@onready var CardsDatabase = preload("res://cards_database.gd");
var Cardname = 'Agumon';
@onready var CardInformation = CardsDatabase.DATA[Cardname];
@onready var CardImg = str("res://digimon-images/", CardInformation.name,".jpg")

# Called when the node enters the scene tree for the first time.
func _ready():
	print(CardInformation)
	var CardSize = Vector2(254, 350)
	
	#$Border.scale *= CardSize / $Border.texture.get_size();
	var baseWidth = $CardImage.texture.get_size().x * 0.355
	var baseHeight = $CardImage.texture.get_size().y * 0.343
	
	$CardImage.texture = load(CardImg)
	var imgWidth = $CardImage.texture.get_size().x
	var imgHeight = $CardImage.texture.get_size().y
	
	var scale_factor_width = baseWidth / imgWidth
	var scale_factor_height = baseHeight / imgHeight
	
	$CardImage.scale = Vector2(scale_factor_width, scale_factor_height)

	#$CardImage.offset = Vector2(200,200)
	
	#$CardImage.scale = Vector2(240 / $CardImage.texture.get_size().x, 190 / $CardImage.texture.get_size().y)
	#$CardImage.scale *= CardSize / $CardImage.texture.get_size();
	var attack = CardInformation.attack
	var deffense = CardInformation.deffense
	var color = CardInformation.color
	var name = CardInformation.name
	
	print($CardImage.texture.get_size() * $CardImage.scale)
	
	$Name.text = str(name)
	$Atk.text = str(attack)
	$Hp.text = str(deffense)
	
	var styleBoxFlat = $Panel.get_theme_stylebox("theme_override_styles/panel")
	if styleBoxFlat is StyleBoxFlat:
		if color == CardsDatabase.COLORS.get("RED"):
			styleBoxFlat.border_color = Color(1, 0, 0, 1)  # Rojo
		if color == CardsDatabase.COLORS.get("BLUE"):
			styleBoxFlat.border_color = Color(100, 2, 0)  # Rojo
	#$Bars.scale = CardSize / $Border.texture.get_size();
	#$Bars/NameLabel.text = name;
	#$Bars/AttackLabel.text = str(attack);
	#$Bars/DeffenseLabel.text = str(deffense);


func _draw():
	var rect = Rect2(Vector2(50, 50), Vector2(200, 229)) # Define el área del rectángulo
	var radius = 20 # Radio de las esquinas redondeadas
	var style = StyleBoxFlat.new()
	style.bg_color = Color(255, 255, 255, 0)

	draw_style_box(style, rect) # Dibuja el fondo
	draw_arc(Vector2(rect.position.x + radius, rect.position.y + radius), radius, PI, PI + 0.5 * PI, 10, Color(1, 0, 0)) # Esquina superior izquierda
	draw_arc(Vector2(rect.position.x + rect.size.x - radius, rect.position.y + radius), radius, PI + 0.5 * PI, 2* PI, 10, Color(1, 0, 0)) # Esquina superior derecha
	draw_arc(Vector2(rect.position.x + radius, rect.position.y + rect.size.y - radius), radius, PI, PI/2, 10, Color(1, 0, 0)) # Esquina inferior izquierda
	draw_arc(Vector2(rect.position.x + rect.size.x - radius, rect.position.y + rect.size.y - radius), radius, 2*PI, 2*PI+0.5*PI, 10, Color(1, 0, 0)) # Esquina inferior derecha


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
