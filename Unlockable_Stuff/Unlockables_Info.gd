extends Node
# Holds Titles, Avatar paths and strings that show how to unlock them

# ID: [title,unlock_method]
const TITLES = {
	# 0-9
	0: ["ANONYMOUS PLAYER","UNLOCKED AT THE START"],
	1: ["JUST WANNA HAVE FUN","UNLOCKED AT THE START"],
	2: ["MISCHIEVOUS TROLL","UNLOCKED AT THE START"],
	3: ["DEPRESSED+REPRESSED","LOSE A GAME"],
	4: ["FAKE FRIEND","WIN A GAME"],
	5: ["SEND HELP","LOSE 5 GAMES"],
	6: ["CERTIFIED TRYHARD","WIN 5 GAMES"],
	7: ["NO MORE FRIENDS","PLAY 20 GAMES"],
	8: ["SECOND NAME: GYM","TRAVEL 150 TILES IN A SINGLE GAME"],
	9: ["PERSISTENT","GET SENT BACK TO THE START THRICE IN A SINGLE GAME"],
	# 10-19
	10: ["RESOURCEFUL","DRAW 10 RED CARDS IN A SINGLE GAME"],
	11: ["LOOSE CANNON","DRAW 20 BLACK CARDS IN A SINGLE GAME"],
	12: ["LIVING ON A PRAYER","DRAW 2 ORANGE CARDS IN A SINGLE GAME"],
	13: ["VICTIM","DISCARD 3 OR MORE RED CARDS IN A SINGLE GAME"],
	14: ["SPEEDRUNNER","WIN A GAME IN LESS THAN 20 MINUTES"],
	15: ["STEADY NERVES","WIN A GAME IN 45 MINUTES OR MORE"],
	16: ["HOLIDAYS RUINED","PLAY DURING CHRISTMAS"],
	17: ["ACTUAL CRIMINAL","SEND SOMEONE TO THE START 5 TIMES IN A SINGLE GAME"],
	18: ["MAIN CHARACTER","PULL OFF A COMBO"],
	19: ["PLAYER OF NO REKNOWN","DRAW FEWER RED CARDS THAN OTHER PLAYERS AND STILL WIN"],
	# Extra stuff
	-1: ["BOT",""],
}

# ID: [path,unlock_method]
const AVATARS = {
	# 0-9
	0: ["res://Unlockable_Stuff/Avatars/Anonymous_Player.png","UNLOCKED AT THE START"],
	1: ["res://Unlockable_Stuff/Avatars/Dynamite.png","UNLOCKED AT THE START"],
	2: ["res://Unlockable_Stuff/Avatars/Scope.png","UNLOCKED AT THE START"],
	3: ["res://Unlockable_Stuff/Avatars/Handshake.png","UNLOCKED AT THE START"],
	4: ["res://Unlockable_Stuff/Avatars/Dollar.png","UNLOCKED AT THE START"],
	5: ["res://Unlockable_Stuff/Avatars/NoWifi.png","LOSE 3 GAMES"],
	6: ["res://Unlockable_Stuff/Avatars/Medal.png","WIN 3 GAMES"],
	7: ["res://Unlockable_Stuff/Avatars/FFFF.png","PLAY 10 GAMES"],
	8: ["res://Unlockable_Stuff/Avatars/Frozen.png","SKIP 5 TURNS IN A SINGLE GAME"],
	9: ["res://Unlockable_Stuff/Avatars/Life_Sentence.png","GET JAILED THRICE IN A SINGLE GAME"],
	# 10-19
	10: ["res://Unlockable_Stuff/Avatars/Triple_Seven.png","HOLD A HAND OF 7 CARDS"],
	11: ["res://Unlockable_Stuff/Avatars/Thumbs_Up_Beanie.png","MAKE PLAYERS GO BACK 100 TILES IN A SINGLE GAME"],
	12: ["res://Unlockable_Stuff/Avatars/Beanapped.png","NEGATE 10 BLACK CARDS"],
	13: ["res://Unlockable_Stuff/Avatars/Punch_Through.png","ACTIVATE 3 REACTIONS IN A SINGLE GAME"],
	14: ["res://Unlockable_Stuff/Avatars/Coat-of-Arms.png","DRAW 100 CARDS"],
	15: ["res://Unlockable_Stuff/Avatars/Gym\'s_My_Second_Name.png","PLAY FOR 24 HOURS"],
	16: ["res://Unlockable_Stuff/Avatars/Zombird.png","PLAY DURING HALLOWEEN"],
	17: ["res://Unlockable_Stuff/Avatars/Clowned.png","LOSE A GAME WHILE STILL AT THE START"],
	18: ["res://Unlockable_Stuff/Avatars/Doom.png","WIN A GAME WITH THE OTHER PLAYERS NOT EVEN AT TILE 18"],
	19: ["res://Unlockable_Stuff/Avatars/Gleam.png","REFLECT A CERTAIN POWERFUL RED CARD"],
	# Extra stuff
	-1: ["res://Unlockable_Stuff/Avatars/Locked_Avatar.png",""],
}
