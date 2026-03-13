extends Node
class_name Room


var connections = []
var room_name
var id
var background
var explore_events = {}
var is_sleeping_spot = false
var explore_items = {}
var explore_times_max = 5
@onready var explore_times = explore_times_max

func get_explore_event():
	var rng = RandomNumberGenerator.new()
	if explore_events.size() == 0:
		return "empty"
	else:
		var event_array = []
		for event in explore_events.keys():
			event_array.append(event)
		var weights = []
		for weight in explore_events:
			weights.append(explore_events[weight])
		print(event_array)
		print(weights)
		return event_array[rng.rand_weighted(weights)]

func get_explore_item():
	var rng = RandomNumberGenerator.new()
	if explore_items.size() == 0:
		return "empty"
	else:
		var event_array = []
		for event in explore_items.keys():
			event_array.append(event)
		var weights = []
		for weight in explore_items:
			weights.append(explore_items[weight])
		print(event_array)
		print(weights)
		return event_array[rng.rand_weighted(weights)]

func reset_map():
	explore_times = explore_times_max
