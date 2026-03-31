extends Node

var room_list = {}
var actor_list = {}
var item_list = {}
var player_actor
var active_room
var travel_window
var item_window
var room_astar
var clock = 0

@onready var log_window = $LogWindow
@onready var last_button = $BottomMenu/Move

enum {COMMAND, PROCESS}
var state = COMMAND

signal command_set

func _ready():
	Data.initialize_data()
	set_player_actor("MrHero")
	Data.get_actor(player_actor).room = "Cave"
	start_new_room("Cave")
	make_pathfind()
	last_button.grab_focus()
	connect("command_set", process_commands)
	Data.connect("log", log_window.add_log)

#region game_manager

func process_commands():
	Data.validate_actions()	
	Data.sort_action_queue()
	Data.execute_actions(player_actor)



#endregion

#region actions


	
#endregion
func set_player_actor(actor):
	player_actor = actor
	$PlayerWindow.set_player_window(Data.get_actor(actor))

func old_change_active_room(newroom):
	if Data.has_room(newroom):
		if Data.get_actor(player_actor).damage_energy(5):
			log_window.add_log("Moved to " + newroom)
			spend_time(30)
			start_new_room(newroom)
		else:
			log_window.add_log("No more energy, you collapsed...")
	else:
		log_window.add_log("Tried to move from " + active_room + " to " + newroom + "but the room doesn't exist")
		print("hey bro room does not exist")
		return

func change_active_room(newroom):
	var act = Action.new()
	act.type = "move"
	act.parameters.append(newroom)
	act.actor = player_actor
	Data.add_action(act)
	emit_signal("command_set")
	
func start_new_room(room):
	active_room = room
	var room_data = Data.get_room(room)
	last_button.grab_focus()
	if room_data.background != null:
		$Background.texture = room_data.background
	update_hud()

func update_hud():
	$PlayerWindow.set_player_window(Data.get_actor(player_actor))
	if Data.get_room(active_room).is_sleeping_spot:
		$BottomMenu/Rest.text = "Sleep"
	else:
		$BottomMenu/Rest.text = "Rest"
	$PlayerWindow.update_time(clock)

func make_pathfind():
	var pathfinder = AStar2D.new()
	for i in Data.room_list:
		pathfinder.add_point(Data.get_room(i).id, Vector2.ZERO)
	for i in Data.room_list:
		for j in Data.get_room(i).connections:
			if Data.room_list.has(j):
				pathfinder.connect_points(Data.get_room(i).id, Data.get_room(j).id, false)
	room_astar = pathfinder

func return_pathfind(target):
	var path = room_astar.get_id_path(Data.get_room(active_room).id, Data.get_room(target).id)
	if path.size() > 0:
		print(path)
		print(path.size())
		path.remove_at(0)
		if path.size() <= 0:
			log_window.add_log("You're at " + str(target) + " already.")
			return
		else:
			log_window.add_log("Moving to " + str(target) + ", " + str(path.size()) + " rooms away")
			for i in path:
				change_active_room(Data.find_room_by_id(i))
			
	else:
		log_window.add_log("Tried to move from " + active_room + " to " + str(target) + "but there's no path")
		print("no_path_avaliable")



func spend_time(minutes):
	clock += minutes

#region window buttons
func _on_button_pressed():
	if travel_window == null:
		last_button = $BottomMenu/Move
		travel_window = load("res://TravelWindow.tscn").instantiate()
		travel_window.populate_travel_list(Data.get_room(active_room).connections)
		travel_window.connect("travel_clicked", change_active_room)
		travel_window.connect("focus_exited", last_button.grab_focus)
		add_child(travel_window)
		#travel_window.grab_focus()


func _on_button_2_pressed():
	if travel_window == null:
		last_button = $BottomMenu/Map
		travel_window = load("res://TravelWindow.tscn").instantiate()
		var rooms = []
		for i in Data.room_list.keys():
			rooms.append(i)
		travel_window.populate_travel_list(rooms)
		travel_window.connect("travel_clicked", return_pathfind)
		travel_window.connect("focus_exited", last_button.grab_focus)
		add_child(travel_window)


func _on_talk_pressed():
	pass # Replace with function body.


func _on_explore_pressed():
	var room = Data.get_room(active_room)
	if !Data.get_actor(player_actor).damage_energy(2):
		return
	var event = room.get_explore_event()
	spend_time(15)
	match(event):
		"empty":
			log_window.add_log("There's nothing here")
		"Item":
			log_window.add_log("You search...")
			var item = room.get_explore_item()
			if Data.has_item(item):
				if Data.get_actor(player_actor).add_item(item):
					log_window.add_log("You found " + item + "!")
				else:
					log_window.add_log("You found " + item + ", but your inventory is full...")
			else:
				log_window.add_log("You found " + item + " but it doesn't exist in the database!")
		"Nothing":
			log_window.add_log("You search... didn't find anything")
		"Encounter":
			log_window.add_log("You encounter a creature!")
	$PlayerWindow.set_player_window(Data.get_actor(player_actor))


func _on_rest_pressed():
	if Data.get_room(active_room).is_sleeping_spot:
		if (clock/60)+9 > 20 or Data.get_actor(player_actor).energy == 0:
			log_window.add_log("ZzZz... You feel well rested!")
			clock = 0
			Data.get_actor(player_actor).damage_energy(-999)
			Data.get_actor(player_actor).damage_hp(-999)
		else:
			log_window.add_log("You are not sleepy.")
	else:
		if (clock/60)+9 > 20:
			log_window.add_log("You should find somewhere to sleep")
		else:
			log_window.add_log("You rest for a while")
			spend_time(60)
			Data.get_actor(player_actor).damage_energy(-20)
			Data.get_actor(player_actor).damage_hp(-5)
	update_hud()


func _on_item_pressed():
	if item_window == null:
		last_button = $BottomMenu/Item
		item_window = load("res://item_menu.tscn").instantiate()
		var item_icons = []
		for item in Data.get_actor(player_actor).inventory:
			item_icons.append(Data.get_item(item).icon)
		item_window.populate_item_list(item_icons)
		#item_window.connect("travel_clicked", change_active_room)
		item_window.connect("focus_exited", last_button.grab_focus)
		item_window.connect("item_used", item_used)
		item_window.connect("item_info", item_info)
		item_window.connect("item_discard", item_discard)
		add_child(item_window)
	pass # Replace with function body.

#endregion

func item_used(index):
	var item = Data.get_actor(player_actor).inventory[index]
	if Data.get_item(item).usable:
		if Data.get_item(item).consumable:
			Data.get_actor(player_actor).inventory.remove_at(index)
		log_window.add_log("You used " + item)
	else:
		log_window.add_log(item + " is not usable.")
	last_button.grab_focus()

func item_info(index):
	var item = Data.get_actor(player_actor).inventory[index]
	log_window.add_log(Data.get_item(item).info_text)
	last_button.grab_focus()
func item_discard(index):
	var item = Data.get_actor(player_actor).inventory[index]
	if Data.get_item(item).droppable:
		Data.get_actor(player_actor).inventory.remove_at(index)
		log_window.add_log("You dropped " + item)
	else:
		log_window.add_log("You can't drop " + item)
	last_button.grab_focus()
