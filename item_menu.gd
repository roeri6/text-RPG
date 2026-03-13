extends ItemList



func populate_item_list(list):
	clear()
	for item in list:
		add_item("", item)
	call_deferred("grab_focus")
	show()
	select(0)


func _on_gui_input(event):
	if event.is_action_pressed("ui_cancel"):
		emit_signal("focus_exited")
		queue_free()
