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
var room
var current_action : Action

var inventory = []
var inventory_slots = 10

func change_room(newroom):
	room = newroom

func add_item(item):
	if inventory.size() < inventory_slots:
		inventory.append(item)
		return true
	else:
		return false

func damage_hp(value):
	hp = clampi(hp-value,0, max_hp)
	return hp

func damage_energy(value):
	if value < 0:
		energy = clampi(energy-value,0, max_energy)
		return true
	if energy > value:
		energy -= value
		return true
	else:
		if energy > 0:
			value -= energy
			energy = 0
		hp -= value
		if hp > 0:
			return true
		else:
			return false

func set_action(act):
	current_action = act
