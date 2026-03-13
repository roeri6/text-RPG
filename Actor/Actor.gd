extends Node
class_name Actor


var id
var actor_name
var hp = 50
var max_hp = 50
var mana = 10
var max_mana = 10
var energy = 50
var max_energy = 50

var inventory = []
var inventory_slots = 10

func add_item(item):
	if inventory.size() < inventory_slots:
		inventory.append(item)
		return true
	else:
		return false
