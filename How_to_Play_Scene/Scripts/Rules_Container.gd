extends MarginContainer
# Handles the rule panels

var rules_panels: Array
var hand_card_layer: CanvasLayer
var ex_card_layers: Array

func _ready():
	# Prep
	rules_panels.append($Start_Rules)
	rules_panels.append($Turns_Rules)
	rules_panels.append($Cards_Rules)
	rules_panels.append($Tiles_Rules)
	hand_card_layer = $Turns_Rules/Hand_Card_Layer
	ex_card_layers.append($Cards_Rules/Red_Card_Layer)
	ex_card_layers.append($Cards_Rules/Reaction_Layer)
	ex_card_layers.append($Cards_Rules/Black_Card_Layer)
	ex_card_layers.append($Cards_Rules/Orange_Card_Layer)
	var card_info_panel: Panel = $Cards_Rules/Card_Info_Layer/Card_Info
	card_info_panel.initialize()
	hand_card_layer.get_child(0).initialize(12,"Red",null)
	ex_card_layers[0].get_child(0).initialize(18,"Red",card_info_panel)
	ex_card_layers[1].get_child(0).initialize(41,"Red",card_info_panel)
	ex_card_layers[2].get_child(0).initialize(35,"Black",card_info_panel)
	ex_card_layers[3].get_child(0).initialize(7,"Orange",card_info_panel)
	# Translation
	rules_panels[0].get_node("Label").text = tr("BEFORE THE START OF THE GAME EACH PLAYER CHOOSES A COLOR")
	rules_panels[0].get_node("Label2").text = tr("THEN EACH PLAYER ROLLS A DICE")
	rules_panels[1].get_node("Label").text = tr("DURING YOUR TURN YOU CAN ROLL THE DICE")
	rules_panels[1].get_node("Label2").text = tr("BEFORE DOING THAT, YOU CAN ALSO PLAY A RED CARD")
	rules_panels[2].get_node("Red_Cards").text = tr("RED CARDS")
	rules_panels[2].get_node("Label").text = tr("HELPFUL CARDS THAT ARE ADDED")
	rules_panels[2].get_node("Black_Orange_Cards").text = tr("BLACK/ORANGE CARDS")
	rules_panels[2].get_node("Label2").text = tr("CARDS WITH MIXED EFFECTS ACTIVATED IMMEDIATELY")
	rules_panels[2].get_node("Reactions").text = tr("REACTIONS")
	rules_panels[2].get_node("Label3").text = tr("RED CARDS WITH SPECIAL ACTIVATION")
	rules_panels[2].get_node("Label4").text = tr("TAP ON A CARD TO READ ITS EFFECT")
	if TranslationServer.get_locale()=="it":
		rules_panels[2].get_node("Label4").rect_position = Vector2(565,0)
		rules_panels[2].get_node("Label4").rect_size = Vector2(415,25)
	rules_panels[3].get_node("Label").text = tr("DIFFERENT TYPES OF TILE")
	rules_panels[3].get_node("Tiles/Label").text = tr("DRAW A RED CARD")
	rules_panels[3].get_node("Tiles/Label2").text = tr("DRAW A BLACK CARD")
	rules_panels[3].get_node("Tiles/Label3").text = tr("DRAW AN ORANGE CARD")
	rules_panels[3].get_node("Tiles/Label4").text = tr("ROLL AGAIN")
	rules_panels[3].get_node("Tiles/Label5").text = tr("SKIP YOUR NEXT TURN")
	rules_panels[3].get_node("Tiles/Label6").text = tr("MOVE UP 1 TILE OR GET A RED CARD FROM AN OPPONENT")
	rules_panels[3].get_node("Tiles/Label7").text = tr("ROLL ODD/EVEN AND GO TO THE TILE POINTED")
	rules_panels[3].get_node("Tiles/Label8").text = tr("GO BACK TO THE START")
	rules_panels[3].get_node("Tiles/Label9").text = tr("STAY IN JAIL FOR 2 TURNS")
	rules_panels[3].get_node("Tiles/Label10").text = tr("VICTORY")

func _change_panel(p: int):
	AudioController.play_turnpage() # Sound
	for n in 4: rules_panels[n].visible = p==n
	if p==1: hand_card_layer.show()
	else: hand_card_layer.hide()
	if p==2: for n in 4: ex_card_layers[n].show()
	else: for n in 4: ex_card_layers[n].hide()
