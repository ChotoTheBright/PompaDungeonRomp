extends Node

signal dead
signal hurt
signal healed
signal health_changed
signal gibbed

var max_health = 100 #
var cur_health# = 1

##items
var throwing_knife : int = 5
var sleep_gas : int = 2
var fuzzy_dust : int = 0
var web_ball : int = 0
var sphere : int = 0
var bandage_heal : int = 4
var potion_heal : int = 0

var defending : bool = false

export var gib_at = -10


func _ready():
	init()
	
func init():
	cur_health = max_health
	emit_signal("health_changed", cur_health)

func hurt(damage: float): #, _dir: Vector3

	if cur_health <= 0:
		return
	if defending and damage > 0:
		damage = damage * .5
	cur_health = clamp(cur_health - damage, 0, 100)
	if cur_health <= gib_at:
		emit_signal("gibbed")
		pass
	if cur_health <= 0:
		emit_signal("dead")
	else:
		emit_signal("hurt")
	emit_signal("health_changed", cur_health)
	
func heal(amount: float):
	if cur_health <= 0:
		return
	cur_health += amount
	if cur_health > max_health:
		cur_health = max_health
	emit_signal("healed")
	emit_signal("health_changed", cur_health)

func set_status(status: String):

	self.set(status, true)

	print(status)


func use_item(item : String, amount : int):
	

	set(item, get(item) + amount)
