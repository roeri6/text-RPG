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

func _ready():
	create_item("Carrot", "A tasty vegetable", load("res://Theme/carrot.png"))
	create_item("Meat", "Nice to meat you", load("res://Theme/meat.png"))
	create_room("Cave Entrance",["Forest","Cave"], load("res://Room/Backgrounds/clearing.png"))
	create_room("Cave",["Cave Entrance"],load("res://Room/Backgrounds/cave.png"),{}, true)
	create_room("Forest",["Cave Entrance","Dirt Road"], load("res://Room/Backgrounds/forest.png"), {"Item": 50, "Nothing":50, "Encounter": 25}, false, {"Carrot" : 1, "Meat": 1})
	create_room("Dirt Road",["Forest"], load("res://Room/Backgrounds/dirtroad.png"))
	#create_room("GodRoom",[])
	create_actor("MrHero")
	set_player_actor("MrHero")
	start_new_room("Cave")
	make_pathfind()
	last_button.grab_focus()

func create_room(rname,rconnections, background, revent = {}, rsleep = false, ritems = {}):
	var newroom = Room.new()
	newroom.room_name = rname
	newroom.connections.append_array(rconnections)
	newroom.explore_events = revent.duplicate()
	newroom.explore_items = ritems.duplicate()
	newroom.is_sleeping_spot = rsleep
	newroom.background = background
	room_list[newroom.room_name] = newroom
	newroom.id = room_list.size()

func create_item(iname, infotext, icon):
	var newitem = Item.new()
	newitem.item_name = iname
	newitem.info_text = infotext
	newitem.icon = icon
	item_list[newitem.item_name] = newitem
	newitem.id = item_list.size()
	
func create_actor(aname):
	var newactor = Actor.new()
	newactor.actor_name = aname
	actor_list[aname] = newactor
	newactor.id = actor_list.size()

func set_player_actor(actor):
	player_actor = actor
	$PlayerWindow.set_player_window(actor_list[actor])

func change_active_room(newroom):
	if room_list.has(newroom):
		if spend_energy(5):
			log_window.add_log("Moved to " + newroom)
			spend_time(30)
			start_new_room(newroom)
		else:
			log_window.add_log("No more energy, you collapsed...")
	else:
		log_window.add_log("Tried to move from " + active_room + " to " + newroom + "but the room doesn't exist")
		print("hey bro room does not exist")
		return

func start_new_room(room):
	active_room = room
	last_button.grab_focus()
	if room_list[active_room].background != null:
		$Background.texture = room_list[active_room].background
	#$Window.title = room
	#$Window/Label.text = room
	update_hud()

func update_hud():
	$PlayerWindow.set_player_window(actor_list[player_actor])
	if room_list[active_room].is_sleeping_spot:
		$BottomMenu/Rest.text = "Sleep"
	else:
		$BottomMenu/Rest.text = "Rest"
	$PlayerWindow.update_time(clock)
	
func make_pathfind():
	var pathfinder = AStar2D.new()
	for i in room_list:
		pathfinder.add_point(room_list[i].id, Vector2.ZERO)
	for i in room_list:
		for j in room_list[i].connections:
			if room_list.has(j):
				pathfinder.connect_points(room_list[i].id, room_list[j].id, false)
	room_astar = pathfinder

func return_pathfind(target):
	var path = room_astar.get_id_path(room_list[active_room].id, room_list[target].id)
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
				change_active_room(find_room_by_id(i))
			
	else:
		log_window.add_log("Tried to move from " + active_room + " to " + str(target) + "but there's no path")
		print("no_path_avaliable")

func find_room_by_id(id):
	for i in room_list:
		if room_list[i].id == id:
			return i
	return null

func spend_energy(value):
	if value < 0:
		actor_list[player_actor].energy = clampi(actor_list[player_actor].energy-value,0, actor_list[player_actor].max_energy)
		return true
	if actor_list[player_actor].energy > value:
		actor_list[player_actor].energy -= value
		return true
	else:
		if actor_list[player_actor].energy > 0:
			value -= actor_list[player_actor].energy
			actor_list[player_actor].energy = 0
		actor_list[player_actor].hp -= value
		if actor_list[player_actor].hp > 0:
			log_window.add_log("No more energy, you're too tired...")
			return true
		else:
			log_window.add_log("You collapse...")
			return false

func spend_hp(value):
	actor_list[player_actor].hp = clampi(actor_list[player_actor].hp-value,0, actor_list[player_actor].max_hp)
	
func spend_time(minutes):
	clock += minutes
	
func _on_button_pressed():
	if travel_window == null:
		last_button = $BottomMenu/Move
		travel_window = load("res://TravelWindow.tscn").instantiate()
		travel_window.populate_travel_list(room_list[active_room].connections)
		travel_window.connect("travel_clicked", change_active_room)
		travel_window.connect("focus_exited", last_button.grab_focus)
		add_child(travel_window)
		#travel_window.grab_focus()


func _on_button_2_pressed():
	if travel_window == null:
		last_button = $BottomMenu/Map
		travel_window = load("res://TravelWindow.tscn").instantiate()
		var rooms = []
		for i in room_list.keys():
			rooms.append(i)
		travel_window.populate_travel_list(rooms)
		travel_window.connect("travel_clicked", return_pathfind)
		travel_window.connect("focus_exited", last_button.grab_focus)
		add_child(travel_window)
	pass # Replace with function body.


func _on_talk_pressed():
	pass # Replace with function body.


func _on_explore_pressed():
	if !spend_energy(2):
		return
	var event = room_list[active_room].get_explore_event()
	spend_time(15)
	match(event):
		"empty":
			log_window.add_log("There's nothing here")
		"Item":
			log_window.add_log("You search...")
			var item = room_list[active_room].get_explore_item()
			if item_list.has(item):
				if actor_list[player_actor].add_item(item):
					log_window.add_log("You found " + item + "!")
				else:
					log_window.add_log("You found " + item + ", but your inventory is full...")
			else:
				log_window.add_log("You found " + item + " but it doesn't exist in the database!")
		"Nothing":
			log_window.add_log("You search... didn't find anything")
		"Encounter":
			log_window.add_log("You encounter a creature!")
	$PlayerWindow.set_player_window(actor_list[player_actor])


func _on_rest_pressed():
	if room_list[active_room].is_sleeping_spot:
		if (clock/60)+9 > 20 or actor_list[player_actor].energy == 0:
			log_window.add_log("ZzZz... You feel well rested!")
			clock = 0
			spend_energy(-999)
			spend_hp(-999)
		else:
			log_window.add_log("You are not sleepy.")
	else:
		if (clock/60)+9 > 20:
			log_window.add_log("You should find somewhere to sleep")
		else:
			log_window.add_log("You rest for a while")
			spend_time(60)
			spend_energy(-20)
			spend_hp(-5)
	update_hud()


func _on_item_pressed():
	if item_window == null:
		last_button = $BottomMenu/Item
		item_window = load("res://item_menu.tscn").instantiate()
		var item_icons = []
		for item in actor_list[player_actor].inventory:
			item_icons.append(item_list[item].icon)
		item_window.populate_item_list(item_icons)
		#item_window.connect("travel_clicked", change_active_room)
		item_window.connect("focus_exited", last_button.grab_focus)
		add_child(item_window)
	pass # Replace with function body.
