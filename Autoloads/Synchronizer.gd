extends Node
# Singleton called to make sure the online players are all on the same page
# NB Some classes that require lots of synchronizing have their own synchronize method to not overburden this autoload

var _peripheral_tool # Whatever node is used by the current scene to show the game is loading
var _sync_n: int = 0 # The number of synchronized players-1

# Setter for the scene-relative tool
func set_peripheral_tool(peripheral_tool) -> void: _peripheral_tool=peripheral_tool

# Used to tell the others you're synchronized
remote func im_ready() -> void: _sync_n+=1

# Synchronize the game scene
# Shows the hourglass animation if it takes time
func synchronize_game() -> void:
	var t:float=0
	if PlayersList.am_on(): rpc("im_ready")
	while _sync_n<(PlayersList.get_apn()-1):
		yield(get_tree().create_timer(.2),"timeout")
		t+=.2
		if t==2.0: _peripheral_tool.appear_to_tell_to_wait()
		print("Waiting for: "+str(t))
	_sync_n = 0
	if t>=2.0: _peripheral_tool.disappear()
	yield(get_tree().create_timer(.1),"timeout")
