extends ItemList

var selected_item

signal item_used
signal item_info
signal item_discard

func populate_item_list(list):
	clear()
	for item in list:
		add_item("", item)
	call_deferred("grab_focus")
	show()
	if list.size() > 0:
		select(0)


func _on_gui_input(event):
	if event.is_action_pressed("ui_cancel"):
		emit_signal("focus_exited")
		queue_free()


func _on_item_activated(index):
	$ItemList.show()
	$ItemList.grab_focus()
	$ItemList.select(0)
	selected_item = index


func _on_item_list_item_activated(index):
	match(index):
		0:
			emit_signal("item_used", selected_item)
		1:
			emit_signal("item_info", selected_item)
		2:
			emit_signal("item_discard", selected_item)
	queue_free()


func _on_item_list_gui_input(event):
	if event.is_action_pressed("ui_cancel"):
		$ItemList.hide()
		grab_focus()
		select(selected_item)
