extends Panel



func set_player_window(data):
	$HP.set_statbar("LIFE", data.hp, data.max_hp)
	#$MP.set_statbar("MANA", data.mana, data.max_mana)
	$ENE.set_statbar("ENE", data.energy, data.max_energy)
	#title = data.actor_name

func update_time(minutes):
	var hours = (minutes/60) + 9
	print(hours)
	#day begins at 9am ends at 9pm
	if hours >= 9:
		$Time.text = "Morning"
	if hours == 12:
		$Time.text = "Noon"
	if hours > 12:
		$Time.text = "Afternoon"
	if hours > 17:
		$Time.text = "Evening"
	if hours > 20:
		$Time.text = "Night"
