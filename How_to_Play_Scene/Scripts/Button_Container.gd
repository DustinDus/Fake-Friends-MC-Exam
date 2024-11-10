extends MarginContainer
# Handles How_to_Play_Scene's buttons to change rule panel

var buttons: Array = []

# Get the buttons
func _ready(): 
	for n in 4: buttons.append($Buttons.get_child(n))
	buttons[0].text = tr("START")
	buttons[1].text = tr("TURNS_CAP")
	buttons[2].text = tr("CARDS")
	buttons[3].text = tr("TILES")

# "Permafocus" only the pressed button
func _highlight_button(p: int = 1):
	for n in 4:
		buttons[n].add_stylebox_override("normal",buttons[n].get_stylebox("focus"))
		buttons[n].disabled = false
	buttons[p].add_stylebox_override("normal",buttons[p].get_stylebox("hover"))
	buttons[p].disabled = true
