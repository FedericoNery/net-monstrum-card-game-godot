extends Node2D

@onready var CardsDatabase = preload("res://cards_database.gd");
var Cardname = 'Agumon';
@onready var CardInformation = CardsDatabase.DATA[Cardname];
@onready var CardImg = str("res://digimon-images/", CardInformation.name,".jpg")
var isSelected = false
var isHovered = false
# Called when the node enters the scene tree for the first time.
func _ready():
	print(CardInformation)
	var CardSize = Vector2(254, 350)
	
	#$Border.scale *= CardSize / $Border.texture.get_size();
	var baseWidth = $Panel/CardImage.texture.get_size().x * $Panel/CardImage.scale.x
	var baseHeight = $Panel/CardImage.texture.get_size().y * $Panel/CardImage.scale.y
	
	$Panel/CardImage.texture = load(CardImg)
	var imgWidth = $Panel/CardImage.texture.get_size().x
	var imgHeight = $Panel/CardImage.texture.get_size().y
	
	var scale_factor_width = baseWidth / imgWidth
	var scale_factor_height = baseHeight / imgHeight
	
	$Panel/CardImage.scale = Vector2(scale_factor_width, scale_factor_height)

	#$Panel/CardImage.offset = Vector2(200,200)
	
	#$Panel/CardImage.scale = Vector2(240 / $Panel/CardImage.texture.get_size().x, 190 / $Panel/CardImage.texture.get_size().y)
	#$Panel/CardImage.scale *= CardSize / $Panel/CardImage.texture.get_size();
	var attack = str(CardInformation.attack)
	var deffense = str(CardInformation.deffense)
	var color = CardInformation.color
	var name = CardInformation.name
	
	print($Panel/CardImage.texture.get_size() * $Panel/CardImage.scale)
	
	$Panel/Name.text = str(name)
	var labelAtkHp = "{atk}/{hp}"
	$Panel/Atk.text = labelAtkHp.format({"atk": attack, "hp": deffense})
	
	var styleBoxFlat: StyleBoxFlat = $Panel.get_theme_stylebox("panel").duplicate()
	var styleBoxFlatName: StyleBoxFlat = $Panel/Name.get_theme_stylebox("normal").duplicate()
	var styleBoxFlatAtk: StyleBoxFlat = $Panel/Atk.get_theme_stylebox("normal").duplicate()
	if styleBoxFlat is StyleBoxFlat:
		if color == CardsDatabase.COLORS.get("RED"):
			styleBoxFlat.border_color = Color.RED
		if color == CardsDatabase.COLORS.get("BLUE"):
			styleBoxFlat.border_color = Color(100, 2, 0)  # Rojo

	if styleBoxFlatName is StyleBoxFlat:
		if color == CardsDatabase.COLORS.get("RED"):
			styleBoxFlatName.border_color = Color.RED
		if color == CardsDatabase.COLORS.get("BLUE"):
			styleBoxFlatName.border_color = Color(100, 2, 0)  # Rojo
				
	print(styleBoxFlatAtk.bg_color)
	if styleBoxFlatAtk is StyleBoxFlat:
		if color == CardsDatabase.COLORS.get("RED"):
			styleBoxFlatAtk.bg_color = Color.DARK_RED
	print(styleBoxFlatAtk.bg_color)
	
	$Panel/Name.remove_theme_stylebox_override("normal")
	$Panel/Name.add_theme_stylebox_override("normal", styleBoxFlatName)
	
	$Panel/Atk.remove_theme_stylebox_override("normal")
	$Panel/Atk.add_theme_stylebox_override("normal", styleBoxFlatAtk)
	
	$Panel.remove_theme_stylebox_override("panel")
	$Panel.add_theme_stylebox_override("panel", styleBoxFlat)
	#$Bars.scale = CardSize / $Border.texture.get_size();
	#$Bars/NameLabel.text = name;
	#$Bars/AttackLabel.text = str(attack);
	#$Bars/DeffenseLabel.text = str(deffense);
	
	#get_parent().connect_card_signals(self)
	$Area2D.mouse_entered.connect(_on_area_2d_mouse_entered)
	$Area2D.mouse_exited.connect(_on_area_2d_mouse_exited)
	$Area2D.input_event.connect(_on_area_2d_input_event)

func _draw():
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_mouse_entered() -> void:
	#alternateColorWhenClick()
	highlight_card(true)
	
func _on_area_2d_mouse_exited() -> void:
	highlight_card(false)
	
func highlight_card(isHovered):
	if(isHovered):
		self.scale = Vector2(1.05, 1.05)
	else:
		self.scale = Vector2(1, 1)
		

func alternateColorWhenClick() -> void:
	var styleBoxFlat: StyleBoxFlat = $Panel.get_theme_stylebox("panel").duplicate()
	
	if styleBoxFlat.border_color == Color.GOLD:
		if CardInformation.color == CardsDatabase.COLORS.get("RED"):
			styleBoxFlat.border_color = Color.RED
	else:
		styleBoxFlat.border_color = Color.GOLD
		
	$Panel.remove_theme_stylebox_override("panel")
	$Panel.add_theme_stylebox_override("panel", styleBoxFlat)	

func moveUp():
	self.position.y = self.position.y - 50

func moveDown():
	self.position.y = self.position.y + 50
	
func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if !isSelected:
			alternateColorWhenClick()
			moveUp()
			isSelected = true
		else:
			alternateColorWhenClick()
			moveDown()
			isSelected = false
			
