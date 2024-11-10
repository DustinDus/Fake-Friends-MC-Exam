# Database for red cards: [Name_Font_Size, Text_Font_Size, ID, Name]
enum {Plus_1a,Plus_1b,Minus_1a,Minus_1b,Plus_2a
	  Plus_2b,Minus_2a,Minus_2b,Plus_3a,Plus_3b
	  Minus_3a,Minus_3b,Plus_4a,Plus_4b,Minus_4a
	  Minus_4b,Plus_5a,Plus_5b,Minus_5a,Minus_5b
	  Plus_6,Minus_6,Ill_Fate,Reversal,Reversal_2
	  Swapain,Swapleasure,Prankz,Prankz_2,Misfortune
	  Back_to_the_Store,Reconciliation,Double_or_Nothing,All_or_Nothing,A_Bad_Day
	  What_a_Terrible_Day,A_Good_Day,LAG,SIKE,Scripted_Match
	  Shots_Fired,Girl_on_Fire,Reset,This_is_a_Fine,MEMZ,
	  Go_to_Jail,Its_all_over,Painful_Sacrifice,On_the_Loose,Gonna_get_Ya}

const DATA = {
	# 0-9
	Plus_1a: [22,20,0,"+1"],
	Plus_1b: [22,20,1,"+1"],
	Minus_1a: [22,20,2,"-1"],
	Minus_1b: [22,20,3,"-1"],
	Plus_2a: [22,20,4,"+2"],
	Plus_2b: [22,20,5,"+2"],
	Minus_2a: [22,20,6,"-2"],
	Minus_2b: [22,20,7,"-2"],
	Plus_3a: [22,20,8,"+3"],
	Plus_3b: [22,20,9,"+3"],
	# 10-19
	Minus_3a: [22,20,10,"-3"],
	Minus_3b: [22,20,11,"-3"],
	Plus_4a: [22,20,12,"+4"],
	Plus_4b: [22,20,13,"+4"],
	Minus_4a: [22,20,14,"-4"],
	Minus_4b: [22,20,15,"-4"],
	Plus_5a: [22,20,16,"+5"],
	Plus_5b: [22,20,17,"+5"],
	Minus_5a: [22,20,18,"-5"],
	Minus_5b: [22,20,19,"-5"],
	# 20-29
	Plus_6: [22,20,20,"MOVE UP!"],
	Minus_6: [22,20,21,"BLASTING OFF!"],
	Ill_Fate: [22,19,22,"ILL FATE"],
	Reversal: [22,19,23,"REVERSAL"],
	Reversal_2: [15,19,24,"REVERSAL 2: THE RETURN"],
	Swapain: [22,14,25,"SWAPAIN"],
	Swapleasure: [22,14,26,"SWAPLEASURE"],
	Prankz: [22,20,27,"PRANKZ"],
	Prankz_2: [15,20,28,"PRANKZ 2: PRANK HARDER"],
	Misfortune: [22,19,29,"MISFORTUNE"],
	# 30-39
	Back_to_the_Store: [20,18,30,"BACK TO THE STORE"],
	Reconciliation: [22,19,31,"RECONCILIATION"],
	Double_or_Nothing: [19,11,32,"DOUBLE OR NOTHING"],
	All_or_Nothing: [22,11,33,"ALL OR NOTHING"],
	A_Bad_Day: [20,20,34,"A BAD DAY"],
	What_a_Terrible_Day: [18,20,35,"WHAT A TERRIBLE DAY"],
	A_Good_Day: [22,18,36,"A GOOD DAY"],
	LAG: [22,17,37,"LAG"],
	SIKE: [22,16,38,"SIKE"],
	Scripted_Match: [22,20,39,"SCRIPTED MATCH"],
	# 40-49
	Shots_Fired: [22,16,40,"SHOTS FIRED!"],
	Girl_on_Fire: [19,12,41,"THIS GIRL IS ON FIRE!"],
	Reset: [22,13,42,"RESET"],
	This_is_a_Fine: [22,16,43,"THIS IS A FINE"],
	MEMZ: [22,22,44,"MEMZ"],
	Go_to_Jail: [22,22,45,"GO TO JAIL"],
	Its_all_over: [22,16,46,"IT'S ALL OVER"],
	Painful_Sacrifice: [18,11,47,"PAINFUL SACRIFICE"],
	On_the_Loose: [20,10,48,"ON THE LOOSE!"],
	Gonna_get_Ya: [20,10,49,"GONNA GET YA!"]
}
