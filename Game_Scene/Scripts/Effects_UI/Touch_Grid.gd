extends Panel
# Handles clicks on the grid

signal tile_was_chosen

# Signals clicked tile
func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		# Gets click position
		var x = event.position.x
		var y = event.position.y 
		if x>2 and x<510 and y>2 and y<510: # Checks if it's in the grid
			AudioController.play_cowbell_os_1() # Sound
		# Checks row first, then column
		if x>2 and x<62:
			if y>2 and y<62: emit_signal("tile_was_chosen",22)
			elif y>66 and y<126: emit_signal("tile_was_chosen",21)
			elif y>130 and y<190: emit_signal("tile_was_chosen",20)
			elif y>194 and y<254: emit_signal("tile_was_chosen",19)
			elif y>258 and y<318: emit_signal("tile_was_chosen",18)
			elif y>322 and y<382: emit_signal("tile_was_chosen",17)
			elif y>386 and y<446: emit_signal("tile_was_chosen",16)
			elif y>440 and y<510: emit_signal("tile_was_chosen",15)
		if x>66 and x<126:
			if y>2 and y<62: emit_signal("tile_was_chosen",23)
			elif y>66 and y<126: emit_signal("tile_was_chosen",44)
			elif y>130 and y<190: emit_signal("tile_was_chosen",43)
			elif y>194 and y<254: emit_signal("tile_was_chosen",42)
			elif y>258 and y<318: emit_signal("tile_was_chosen",41)
			elif y>322 and y<382: emit_signal("tile_was_chosen",40)
			elif y>386 and y<446: emit_signal("tile_was_chosen",39)
			elif y>440 and y<510: emit_signal("tile_was_chosen",14)
		elif x>130 and x<190:
			if y>2 and y<62: emit_signal("tile_was_chosen",24)
			elif y>66 and y<126: emit_signal("tile_was_chosen",45)
			elif y>130 and y<190: emit_signal("tile_was_chosen",58)
			elif y>194 and y<254: emit_signal("tile_was_chosen",57)
			elif y>258 and y<318: emit_signal("tile_was_chosen",56)
			elif y>322 and y<382: emit_signal("tile_was_chosen",55)
			elif y>386 and y<446: emit_signal("tile_was_chosen",38)
			elif y>440 and y<510: emit_signal("tile_was_chosen",13)
		elif x>194 and x<254:
			if y>2 and y<62: emit_signal("tile_was_chosen",25)
			elif y>66 and y<126: emit_signal("tile_was_chosen",46)
			elif y>130 and y<190: emit_signal("tile_was_chosen",59)
			elif y>194 and y<254: emit_signal("tile_was_chosen",64)
			elif y>258 and y<318: emit_signal("tile_was_chosen",63)
			elif y>322 and y<382: emit_signal("tile_was_chosen",54)
			elif y>386 and y<446: emit_signal("tile_was_chosen",37)
			elif y>440 and y<510: emit_signal("tile_was_chosen",12)
		elif x>258 and x<318:
			if y>2 and y<62: emit_signal("tile_was_chosen",26)
			elif y>66 and y<126: emit_signal("tile_was_chosen",47)
			elif y>130 and y<190: emit_signal("tile_was_chosen",60)
			elif y>194 and y<254: emit_signal("tile_was_chosen",61)
			elif y>258 and y<318: emit_signal("tile_was_chosen",62)
			elif y>322 and y<382: emit_signal("tile_was_chosen",53)
			elif y>386 and y<446: emit_signal("tile_was_chosen",36)
			elif y>440 and y<510: emit_signal("tile_was_chosen",11)
		elif x>322 and x<382:
			if y>2 and y<62: emit_signal("tile_was_chosen",27)
			elif y>66 and y<126: emit_signal("tile_was_chosen",48)
			elif y>130 and y<190: emit_signal("tile_was_chosen",49)
			elif y>194 and y<254: emit_signal("tile_was_chosen",50)
			elif y>258 and y<318: emit_signal("tile_was_chosen",51)
			elif y>322 and y<382: emit_signal("tile_was_chosen",52)
			elif y>386 and y<446: emit_signal("tile_was_chosen",35)
			elif y>440 and y<510: emit_signal("tile_was_chosen",10)
		elif x>386 and x<446:
			if y>2 and y<62: emit_signal("tile_was_chosen",28)
			elif y>66 and y<126: emit_signal("tile_was_chosen",29)
			elif y>130 and y<190: emit_signal("tile_was_chosen",30)
			elif y>194 and y<254: emit_signal("tile_was_chosen",31)
			elif y>258 and y<318: emit_signal("tile_was_chosen",32)
			elif y>322 and y<382: emit_signal("tile_was_chosen",33)
			elif y>386 and y<446: emit_signal("tile_was_chosen",34)
			elif y>440 and y<510: emit_signal("tile_was_chosen",9)
		elif x>440 and x<510:
			if y>2 and y<62: emit_signal("tile_was_chosen",1)
			elif y>66 and y<126: emit_signal("tile_was_chosen",2)
			elif y>130 and y<190: emit_signal("tile_was_chosen",3)
			elif y>194 and y<254: emit_signal("tile_was_chosen",4)
			elif y>258 and y<318: emit_signal("tile_was_chosen",5)
			elif y>322 and y<382: emit_signal("tile_was_chosen",6)
			elif y>386 and y<446: emit_signal("tile_was_chosen",7)
			elif y>440 and y<510: emit_signal("tile_was_chosen",8)
