extends ItemList


signal travel_clicked

func populate_travel_list(list):
	clear()
	for room in list:
		add_item(room)
	call_deferred("grab_focus")
	select(0)

	


func _on_item_activated(index):
	emit_signal("travel_clicked", get_item_text(index))
	queue_free()


func _on_item_clicked(index, at_position, mouse_button_index):
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		emit_signal("travel_clicked", get_item_text(index))
		queue_free()


func _on_gui_input(event):
	if event.is_action_pressed("ui_cancel"):
		emit_signal("focus_exited")
		queue_free()
	pass # Replace with function body.
