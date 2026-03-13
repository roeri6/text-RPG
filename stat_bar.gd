extends Control

func update_value(newvalue):
	$ProgressBar.value = newvalue

func set_statbar(statname, statvalue, statmaxvalue):
	$Name.text = statname
	$Value.text = "(" + str(statvalue) + "/" + str(statmaxvalue) + ")"
	$ProgressBar.value = statvalue
	$ProgressBar.max_value = statmaxvalue
	if statname == "ENE":
		var newcolor = StyleBoxFlat.new()
		newcolor.bg_color = Color(0.0, 1.0, 1.0, 1.0)
		$ProgressBar.add_theme_stylebox_override("fill",newcolor)
	else:
		var newcolor = StyleBoxFlat.new()
		newcolor.bg_color = Color(0.05, 1.0, 0.0, 1.0)
		$ProgressBar.add_theme_stylebox_override("fill",newcolor)
