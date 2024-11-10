extends Control
# Shows current avatar and the number of avatars unlocked

var avatars: Dictionary
var current_avatar

# Init
func _ready():
	avatars = UnlockablesInfo.AVATARS
	current_avatar = $Avatar_Border_1/Avatar_Border_2/Sprite
	current_avatar.texture = load(avatars[User.get_avatar()][0])

# Translation
func translate():
	$Option_Name.text = tr("AVATAR") + ":"
	$Change_Avatar.text = tr("AVATARS")
	check_unlocks()

# Check the unlocks and shows some text
func check_unlocks():
	var player_avatars: Array = User.get_avatars()
	var unlocks: int = player_avatars.count(true)
	$How_Many_Avatars.text = tr("AVATARS UNLOCKED")+":\n"+str(unlocks)+"/20"
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
		$Comment.text = tr("ALL AVATARS GOT")
		$Comment.set("custom_colors/font_color",Color("#00ffec")) # 0,.7,.0

# Change User's avatar
func _change_avatar(avatar: int):
	User.set_avatar(avatar)
	current_avatar.texture = load(avatars[User.get_avatar()][0])
