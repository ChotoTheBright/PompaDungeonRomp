extends Area

enum EVENTS {BATTLE, CUTSCENE, DOOR, ITEM, SWITCH}
export(EVENTS) var event_type

onready var col = $Col #Triggers must have a collis.shape with this name

signal event1
signal event2
signal event3
signal event4

func _ready():
	pass

func on_body_entered(body):
	if body.is_in_group("player"):# is StaticBody:
#		return
		emit_signal("event1")
		emit_signal("event2")
		emit_signal("event3")
		emit_signal("event4")
		col.disabled = true
		print("check me out, boyo")
		return










#
#extends Area
#class_name Pickup
#enum PICKUP_TYPES {PISTOLS, SHOTGUN, AUTOMATIC, HURACAN, ROCKET_L, BOW, XBOW,
#	AUTOMATIC_AMMO, PISTOL_AMMO, SHOTGUN_AMMO, HURACAN_AMMO, ROCKET_L_AMMO, BOW_AMMO, 
#	XBOW_AMMO, HEALTH, FOOD}
#
#export(PICKUP_TYPES) var pickup_type
#export var ammo = 20
#export var rotating = false
#export var is_food = false
#
#onready var anim_player = $AnimationPlayer
#
#func _ready():
#	if rotating == true:
#		anim_player.play("rotate")
