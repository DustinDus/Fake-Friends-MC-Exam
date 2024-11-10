extends Control
# Shows current title and number of titles unlocked

var titles: Dictionary
var current_title

# Init
func _ready():
	titles = UnlockablesInfo.TITLES
	current_title = $Current_Title

# Translation
func translate():
	$Change_Title.text = tr("TITLES")
	current_title.text = tr("TITLE")+": "+tr(titles[User.get_title()][0])
	check_unlocks()

# Check the unlocks and shows some text
func check_unlocks():
	var player_titles: Array = User.get_titles()
	var unlocks: int = player_titles.count(true)
	$How_Many_Titles.text = tr("TITLES UNLOCKED")+": "+str(unlocks)+"/20"
	if unlocks<6:
		$Comment.text = tr("PLAY TO UNLOCK MORE")
		$Comment.set("custom_colors/font_color",Color("#bf4b00")) # .2,0,0
	elif unlocks<11:
		$Comment.text = tr("VERY NICE")
		$Comment.set("custom_colors/font_color",Color("#ffe800")) # 0,.2,.0
	elif unlocks<16:
		$Comment.text = tr("KEEP EM COMING")
		$Comment.set("custom_colors/font_color",Color("#2eff00")) # 0,.4,.0
	elif unlocks<20:
		$Comment.text = tr("ALMOST THERE")
		$Comment.set("custom_colors/font_color",Color("#00ff8b")) # 0,.6,.0
	else:
		$Comment.text = tr("ALL TITLES GOT")
		$Comment.set("custom_colors/font_color",Color("#00ffec")) # 0,.7,.0

# Change User's title
func _change_title(title: int):
	User.set_title(title)
	current_title.text = tr("TITLE")+": "+tr(titles[User.get_title()][0])
