extends Node


var room_list = {}
var actor_list = {}
var item_list = {}


func initialize_data():
	create_item("Carrot", "A tasty vegetable", load("res://Theme/carrot.png"))
	create_item("Meat", "Nice to meat you", load("res://Theme/meat.png"))
	create_room("Cave Entrance",["Forest","Cave"], load("res://Room/Backgrounds/clearing.png"))
	create_room("Cave",["Cave Entrance"],load("res://Room/Backgrounds/cave.png"),{}, true)
	create_room("Forest",["Cave Entrance","Dirt Road"], load("res://Room/Backgrounds/forest.png"), {"Item": 50, "Nothing":50, "Encounter": 25}, false, {"Carrot" : 1, "Meat": 1})
	create_room("Dirt Road",["Forest"], load("res://Room/Backgrounds/dirtroad.png"))
	#create_room("GodRoom",[])
	create_actor("MrHero")
	
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

func has_room(room):
	return room_list.has(room)
	
func get_room(room):
	return room_list[room]

func find_room_by_id(id):
	for i in room_list:
		if room_list[i].id == id:
			return i
	return null
	
func create_item(iname, infotext, icon):
	var newitem = Item.new()
	newitem.item_name = iname
	newitem.info_text = infotext
	newitem.icon = icon
	item_list[newitem.item_name] = newitem
	newitem.id = item_list.size()

func get_item(item):
	return item_list[item]

func has_item(item):
	return item_list.has(item)
	
func create_actor(aname):
	var newactor = Actor.new()
	newactor.actor_name = aname	
	actor_list[aname] = newactor
	newactor.id = actor_list.size()

func get_actor(aname):
	return actor_list[aname]
