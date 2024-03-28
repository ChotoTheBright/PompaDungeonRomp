extends Node

signal dead
signal hurt
signal healed
signal health_changed
signal gibbed

var max_health = 100 #
var cur_health# = 1

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
